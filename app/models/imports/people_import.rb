class PeopleImport < Import
  def kind
    "people"
  end
  
  def rollback 
    self.people.destroy_all
  end
  
  def process(parsed_row)
    person      = create_person(parsed_row)
  end
  
  def row_valid?(parsed_row)
    person = attach_person(parsed_row)
    return person.valid?
  end
  
  #
  # This used to rollback.  No reason to now
  #
  def create_person(parsed_row)
    Rails.logger.debug("PEOPLE_IMPORT: Importing person")
    person = attach_person(parsed_row)
    Rails.logger.debug("PEOPLE_IMPORT: Attached #{person.inspect}")
    if !person.save
      Rails.logger.debug("PEOPLE_IMPORT: Save failed")
      message = ""
      message = parsed_row.email + ": " unless parsed_row.email.blank?
      message = message + person.errors.full_messages.join(", ")
      
      self.import_errors.create! :row_data => parsed_row.row, :error_message => message
      Rails.logger.debug("PEOPLE_IMPORT: ERROR'D #{person.errors.full_messages.join(", ")}")
      raise Import::RowError, message
    end 
    person  
  end
end