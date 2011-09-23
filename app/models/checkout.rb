class Checkout
  attr_accessor :order, :payment
  attr_reader :athena_order

  def initialize(order, payment)
    @order = order
    @payment = payment
    @customer = payment.customer

    @payment.amount = @order.total
  end

  def valid?
    if order.nil?
      return !!order
    else
      return (!!order and !!payment and payment.valid?)
    end
  end

  def finish
    @person = find_or_create_people_record
    process_fafs_donations
    order.pay_with(@payment)

    if order.approved?
      order_timestamp = Time.now
      create_order(order_timestamp)
      order.finish(@person, order_timestamp)
    end

    order.approved?
  end

  def process_fafs_donations
    organization = order.organizations.first
    return if organization.nil?

    ::Rails.logger.info "Processing FAFS donations"
    if organization.has_active_fiscally_sponsored_project?
      ::Rails.logger.info "Organization #{organization.id} has an active FSP"
      #build FA::Donation from order.donations
      #clear order.donations
      order.donations = []
    else
      ::Rails.logger.info "Organization #{organization.id} does not have an active FSP"
    end
  end

  private

    def find_or_create_people_record
      organization = order.organizations.first
      person = AthenaPerson.find_by_email_and_organization(@customer.email, organization)

      if person.nil?
        params = {
          :first_name      => @customer.first_name,
          :last_name       => @customer.last_name,
          :email           => @customer.email,
          :organization_id => organization.id # DEBT: This doesn't account for multiple organizations per order
        }
        person = AthenaPerson.create(params)
      end
      person
    end

    def create_order(order_timestamp)
      @order.organizations.each do |organization|
        @athena_order = new_order(organization, order_timestamp, @person)
        @athena_order.save!
        OrderMailer.confirmation_for(athena_order).deliver
        @athena_order
      end
    end

    def new_order(organization, order_timestamp, person)
      AthenaOrder.new.tap do |athena_order|
        athena_order.organization    = organization
        athena_order.timestamp       = order_timestamp
        athena_order.person          = @person
        athena_order.transaction_id  = @payment.transaction_id

        #This will break if ActiveResource properly interprets athena_event.organization_id as the integer that it is intended to be
        athena_order << @order.tickets.select { |ticket| AthenaEvent.find(ticket.event_id).organization_id == organization.id.to_s }
        athena_order << @order.donations
      end
    end
end