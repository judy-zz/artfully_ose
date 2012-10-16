class Checkout
  include ActiveSupport::Callbacks
  define_callbacks :payment
  define_callbacks :order
  
  include Ext::Callbacks::Checkout
  
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

    run_callbacks :payment do
      cart.pay_with(@payment)
    end
    
    if cart.approved?
      order_timestamp = Time.now
      
      run_callbacks :order do
        @created_orders = create_order(order_timestamp)
      end
      
      cart.finish(@person, order_timestamp)
    end
    
    cart.approved?
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
