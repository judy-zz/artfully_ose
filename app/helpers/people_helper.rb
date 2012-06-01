module PeopleHelper
  def relationship_name_display(person)
    link_to person.first_name + ' ' + person.last_name, person_path(person)
  end
  
  def display_name(person)
    if person.nil?
      "(none)"
    elsif person.dummy?
      "Anonymous"
    elsif person.last_name.blank? && person.first_name.blank?
      person.email
    else
      "#{person.first_name} #{person.last_name}"
    end
  end
  
  #yuck
  def link_to_person(person)
    link_to display_name(person), person_path(person)
  end
end