module PeopleHelper
  def relationship_name_display(person)
    link_to person.first_name + ' ' + person.last_name, person_path(person)
  end
end