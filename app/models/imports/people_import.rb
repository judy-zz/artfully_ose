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
end