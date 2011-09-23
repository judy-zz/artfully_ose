class Checkout
  attr_accessor :order, :payment

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
    prepare_fafs_donations   
    order.pay_with(@payment)
    process_fafs_donations

    if order.approved?
      order_timestamp = Time.now
      create_order(order_timestamp)
      order.finish(@person, order_timestamp)
    end

    order.approved?
  end

  #This is done in two steps so that we can process the tickets, ensure that the CC is valid etc...
  #Then process with FA
  def prepare_fafs_donations
    organization = order.organizations.first
    return if organization.nil?
          
    ::Rails.logger.info "Processing FAFS donations"
    if organization.has_active_fiscally_sponsored_project?
      ::Rails.logger.info "Organization #{organization.id} has an active FSP"      
      @fafs_donations = order.clear_donations
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
    if organization.has_active_fiscally_sponsored_project?
      @fafs_donations.each do |donation|
        ::Rails.logger.info "Processing donation for #{donation.amount}"
        fa_donation = FA::Donation.from(donation, payment)
        fa_donation.save
        ::Rails.logger.info "Donation processed"
      end  
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
        athena_order = new_order(organization, order_timestamp, @person)
        athena_order.save!
        OrderMailer.confirmation_for(athena_order).deliver
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