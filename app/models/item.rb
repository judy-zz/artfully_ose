class Item < ActiveRecord::Base
  belongs_to :order
  belongs_to :performance

  validates_presence_of :order_id, :product_type, :price, :realized_price, :net
  validates_inclusion_of :product_type, :in => %( Ticket Donation )

  def ticket?
    product_type == "Ticket"
  end

  def donation?
    product_type == "Donation"
  end

  def self.for(prod)
    new.tap { |this| this.product = prod }
  end

  def self.find_by_product(product)
    find(:all, :params => { :productType => product.class.to_s, :productId => product.id })
  end

  def product
    @product ||= find_product
  end

  def product=(product)
    set_product_details_from product
    set_prices_from product
    set_performance_from product if product.respond_to? :show_id
    self.state = "purchased"
    @product = product
  end

  def dup!
    self.class.new(attributes.reject { |key, value| %w( id state ).include? key } )
  end

  def refundable?
    (not modified?) and product.refundable?
  end

  def exchangeable?
    (not modified?) and product.exchangeable?
  end

  def returnable?
    (not modified?) and product.returnable?
  end

  def refund!
    update_attribute(:state, "refunded")
  end

  def to_refund
    dup!.tap do |item|
      item.price = item.price.to_i * -1
      item.realized_price = item.realized_price.to_i * -1
      item.net = item.net.to_i * -1
      item.state = "refund"
    end
  end

  def to_exchange!
    self.price = 0
    self.realized_price = 0
    self.net = 0
    self.state = "exchangee"
  end

  def to_comp!
    self.price = 0
    self.realized_price = 0
    self.net = 0
    self.state = "comped"
  end

  def return!
    update_attribute(:state, "returned")
    product.return! if product.returnable?
  end

  def modified?
    not %w( purchased comped ).include?(state)
  end

  def settled?
    state.eql? "settled"
  end

  def self.find_by_order(order)
    return [] unless order.id?

    self.find_by_order_id(order.id).tap do |items|
      items.each { |item| item.order = order }
    end
  end

  def self.settle(items, settlement)
    if items.blank?
      logger.debug("Item.settle: No items to settle, returning")
      return
    end

    logger.debug("Settling items #{items.collect(&:id).join(',')}")
    patch(items, { :settlementId => settlement.id, :state => :settled })
  end

  def self.find_by_fa_id(fa_id)
    find(:all, :params => { :faId => fa_id }).first
  end

  def self.from_fa_donation(fa_donation, organization, order)
    @item = Item.new({
                            :order_id       => order.id,
                            :product_type   => "Donation",
                            :state          => "settled"
                          })

    @item.organization_id   = organization.id
    @item.copy_fa_donation(fa_donation)
    @item
  end

  def copy_fa_donation(fa_donation)
    self.state             = "settled"
    self.price             = (fa_donation.amount.to_f * 100).to_i
    self.realized_price    = (fa_donation.amount.to_f * 100).to_i
    self.net               = ((fa_donation.amount.to_f * 100) * 0.94).to_i
    self.fs_project_id     = fa_donation.fs_project_id
    self.nongift_amount    = (fa_donation.nongift.to_f * 100).to_i
    self.is_noncash        = fa_donation.is_noncash || false
    self.is_stock          = fa_donation.is_stock || false
    self.reversed_at       = Time.at(fa_donation.reversed_at.to_i) unless fa_donation.reversed_at.nil?
    self.reversed_note     = fa_donation.reversed_note unless fa_donation.reversed_note.nil?
    self.fs_available_on   = fa_donation.fs_available_on unless fa_donation.fs_available_on.nil?
    self.is_anonymous      = fa_donation.is_anonymous || false
  end

  private

    def set_product_details_from(prod)
      self.product_id = prod.id
      self.product_type = prod.class.to_s
    end

    def set_prices_from(prod)
      self.price          = prod.price
      self.realized_price = prod.price - prod.class.fee
      self.net            = (self.realized_price - (self.realized_price * 0.035)).floor
    end

    def set_performance_from(prod)
      self.show_id = prod.show_id
    end

    def find_product
      return if self.product_id.nil?

      begin
        klass = Kernel.const_get(product_type)
        klass.find(product_id)
      rescue NameError
        return nil
      rescue ActiveResource::ResourceNotFound
        return nil
      end
    end
end