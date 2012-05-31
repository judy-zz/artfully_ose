module PeopleHelper
  def relationship_name_display(person)
    link_to person.first_name + ' ' + person.last_name, person_path(person)
  end
  
  #yuck
  def link_to_person(person)
    if person.nil?
      puts "(none)"
    elsif person.dummy?
      link_to "Anonymous", person_path(person)
    elsif person.last_name.blank? && person.first_name.blank?
      link_to person.email, person_path(person)
    else
      link_to "#{person.first_name} #{person.last_name}", person_path(person)
    end
  end
end