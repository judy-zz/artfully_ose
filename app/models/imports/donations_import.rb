class DonationsImport < Import
  include Imports::Rollback
  include ArtfullyOseHelper
  
  def kind
    "donations"
  end
  
  def process(parsed_row)
    row_valid?(parsed_row)
    person        = create_person(parsed_row)
    contribution  = create_contribution(parsed_row, person)
  end
  
  def rollback 
    rollback_orders
    rollback_people
  end
  
  def valid_date?(date_str)
    begin
      DateTime.parse(date_str)
    rescue
      raise Import::RowError, "Invalid date: #{date_str}"
    end    
    true
  end  
  
  def row_valid?(parsed_row)
    raise Import::RowError, "No Deductible Amount included in this row: #{parsed_row.row}" if parsed_row.unparsed_amount.blank?
    raise Import::RowError, "Please include a first name, last name, or email: #{parsed_row.row}" unless attach_person(parsed_row).person_info
    raise Import::RowError, "Please include a payment method in this row: #{parsed_row.row}" if parsed_row.payment_method.blank?
    raise Import::RowError, "Donation type must be 'Monetary' or 'In-Kind': #{parsed_row.row}" unless Action::GIVE_TYPES.include? (parsed_row.donation_type)
    
    valid_date? parsed_row.donation_date
    true
  end
  
  def create_person(parsed_row)
    Rails.logger.info("Import #{id} DONATION_IMPORT: Creating person")
    if !parsed_row.email.blank?
      person = Person.first_or_create(parsed_row.email, self.organization, parsed_row.person_attributes) do |p|
        p.import = self
      end
    else    
      person = attach_person(parsed_row)
      if !person.save
        Rails.logger.info("Import #{id} DONATION_IMPORT: Person save failed")
        self.import_errors.create! :row_data => parsed_row.row, :error_message => person.errors.full_messages.join(", ")
        self.reload
        fail!
      end 
    end
    person  
  end
   
  def create_contribution(parsed_row, person)
    Rails.logger.info("Import #{id} DONATION_IMPORT: Creating contribution")
    occurred_at = parsed_row.donation_date.blank? ? DateTime.now : DateTime.parse(parsed_row.donation_date)
    params = {}
    params[:subtype] = parsed_row.donation_type
    params[:amount] = parsed_row.amount
    params[:nongift_amount] = parsed_row.nongift_amount
    params[:payment_method] = parsed_row.payment_method
    
    params[:organization_id] = self.organization.id
    params[:occurred_at] = occurred_at.to_s
    params[:details] = "Imported by #{user.email} on  #{I18n.l self.created_at_local_to_organization, :format => :date}"
    params[:person_id] = person.id
    params[:creator_id] = user.id
    
    contribution = Contribution.new(params)
    contribution.save(ImportedOrder) do |contribution|
      contribution.order.import_id  = self.id
      contribution.order.save
      contribution.action.import_id = self.id 
      contribution.action.creator = self.user
      contribution.action.details = "Donated #{number_as_cents contribution.order.total}"
      contribution.action.save
    end
    contribution
  end
end