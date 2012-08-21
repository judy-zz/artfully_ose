module PeopleHelper
  def relationship_name_display(person)
    link_to person.first_name + ' ' + person.last_name, person_path(person)
  end
  
  def link_to_person(person)
    link_to person, person
  end
end