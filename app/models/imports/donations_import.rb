class DonationsImport < Import
  def kind
    "donations"
  end
  
  def process(parsed_row)
    row_valid?(parsed_row)
    person        = create_person(parsed_row)
    contribution  = create_contribution(parsed_row, person)
  end
  
  def rollback 
    self.orders.destroy_all
    self.people.destroy_all
  end
  
  def row_valid?(parsed_row)
    raise Import::RowError, 'No Deductible Amount included in this row' if parsed_row.unparsed_amount.blank?
    true
  end
   
  def create_contribution(parsed_row, person)
    occurred_at = parsed_row.donation_date.blank? ? DateTime.now : DateTime.strptime(parsed_row.donation_date, DATE_INPUT_FORMAT)
    params = {}
    params[:subtype] = parsed_row.donation_type
    params[:amount] = parsed_row.amount
    params[:nongift_amount] = parsed_row.nongift_amount
    
    params[:organization_id] = self.organization.id
    params[:occurred_at] = occurred_at.to_s
    params[:details] = "Imported by #{user.email} on #{self.created_at_local_to_organization}"
    params[:person_id] = person.id
    params[:creator_id] = user.id
    
    contribution = Contribution.new(params)
    contribution.save(ImportedOrder) do |contribution|
      contribution.order.import_id  = self.id
      contribution.order.save
      contribution.action.import_id = self.id 
      contribution.action.creator = self.user
      contribution.action.save
    end
    contribution
  end
end