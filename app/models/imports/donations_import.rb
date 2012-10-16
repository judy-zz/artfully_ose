class DonationsImport < Import
  def kind
    "donations"
  end
  
  def process(parsed_row)
    return if !row_valid?(parsed_row)
    person        = create_person(parsed_row)
    contribution  = create_contribution(parsed_row, person)
  end
  
  def row_valid?(parsed_row)
    !parsed_row.unparsed_amount.blank?
  end
   
  def create_contribution(parsed_row, person)
    params = {}
    params[:subtype] = parsed_row.donation_type
    params[:amount] = parsed_row.amount
    
    params[:organization_id] = self.organization.id
    params[:occurred_at] = parsed_row.donation_date || DateTime.now.to_s
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