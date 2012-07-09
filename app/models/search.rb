class Search < ActiveRecord::Base
  attr_accessible :zip, :state, :event_id
  belongs_to :organization
  belongs_to :event
  validates_presence_of :organization_id

  def people
    @people ||= find_people
  end

  private

  def find_people
    people = Person.where(organization_id: organization_id)
    people = people.joins(:address)
    people = people.joins(tickets: {shows: :events}).where("events.id" => event_id) unless event_id.blank?
    people = people.where("addresses.zip" => zip) unless zip.blank?
    people = people.where("addresses.state" => state) unless state.blank?
    people
  end
end
