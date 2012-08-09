class Checkout
  attr_accessor :cart, :payment, :error
  attr_reader :order, :person

  def self.for(cart, payment)
    cart.checkout_class.new(cart, payment)
  end

  def initialize(cart, payment)
    @cart = cart
    @payment = payment
    @customer = payment.customer
    @payment.amount = @cart.total
  end

  def valid?
    unless (!!cart and !!payment and payment.valid?)
      return false
    end
    
    if cart.empty?
      @error = "Your tickets have expired.  Please select your tickets again."
      return false
    end
    
    true
  end

  def finish
    @person = Person.find_or_create(@customer, cart.organizations.first)
    @person.update_address(Address.from_payment(payment), cart.organizations.first.time_zone, nil, "checkout")
    prepare_fafs_donations
    cart.pay_with(@payment)
    
    if cart.approved?
      process_fafs_donations
      order_timestamp = Time.now
      create_order(order_timestamp)
      cart.finish(@person, order_timestamp)
    end

    cart.approved?
  end

  #This is done in two steps so that we can process the tickets, ensure that the CC is valid etc...
  #Then process with FA
  def prepare_fafs_donations
    organization = cart.organizations.first
    return if organization.nil?

    ::Rails.logger.info "Processing FAFS donations"
    if !organization.nil? && organization.has_active_fiscally_sponsored_project?
      ::Rails.logger.info "Organization #{organization.id} has an active FSP"
      @fafs_donations = cart.clear_donations
      donation_total = @fafs_donations.inject(0) { |sum, donation| sum += donation.amount }
      ::Rails.logger.info "Payment amount is #{@payment.amount}"
      @payment.reduce_amount_by(donation_total)
      ::Rails.logger.info "Payment has been reduced to #{@payment.amount}"
    else
      ::Rails.logger.info "Organization #{organization.id} does not have an active FSP"
    end
  end

  #This is done in two steps so that we can process the tickets, ensure that the CC is valid etc...
  #Then process with FA
  def process_fafs_donations
    if !@fafs_donations.blank? && @fafs_donations.first.organization.has_active_fiscally_sponsored_project?
      ::Rails.logger.info "Processing: #{@fafs_donations.size} fafs donations"
      @fafs_donations.each do |donation|
        ::Rails.logger.info "Processing donation for #{donation.amount}"
        fa_donation = FA::Donation.from(donation, payment)
        fa_donation.save
        ::Rails.logger.info "Donation processed"
      end
    else
      ::Rails.logger.info "Either no donations to process or this org does not have an active fsp"
    end
  end

  private
    def create_sub_orders(order_timestamp)
      created_orders = []
      cart.organizations.each do |organization|
        @order = new_order(organization, order_timestamp, @person)
        @order.save!
        OrderMailer.confirmation_for(order).deliver unless @person.dummy? || @person.email.blank?
        created_orders << @order
      end
      created_orders
    end

    def create_order(order_timestamp)
      create_sub_orders(order_timestamp)
    end

    def order_class
      WebOrder
    end

    def new_order(organization, order_timestamp, person)
      order_class.new.tap do |order|
        order.organization                = organization
        order.created_at                  = order_timestamp
        order.person                      = @person
        order.transaction_id              = @payment.transaction_id
        order.service_fee                 = @cart.fee_in_cents
        order.special_instructions        = @cart.special_instructions
        order.payment_method              = @payment.payment_method
        order.per_item_processing_charge  = @payment.per_item_processing_charge

        order << @cart.tickets.select { |ticket| ticket.organization_id == organization.id }
        order << @cart.donations
      end
    end
end
