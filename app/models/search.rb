class Search < ActiveRecord::Base
  attr_accessible :zip, :state, :event_id,
                  :min_lifetime_value, :max_lifetime_value,
                  :min_lifetime_donations, :max_lifetime_donations
  belongs_to :organization
  belongs_to :event
  validates_presence_of :organization_id

  def people
    @people ||= find_people
  end

  private

  def find_people
    people = Person.where(organization_id: organization_id)
    people = people.joins(:address) unless zip.blank? && state.blank?
    people = people.joins(tickets: {show: :event}).where("events.id" => event_id) unless event_id.blank?
    people = people.where("addresses.zip" => zip) unless zip.blank?
    people = people.where("addresses.state" => state) unless state.blank?
    people = people.where("people.lifetime_value >= ?", min_lifetime_value) unless min_lifetime_value.blank?
    people = people.where("people.lifetime_value <= ?", max_lifetime_value) unless max_lifetime_value.blank?
    people = people.where("people.lifetime_donations >= ?", min_lifetime_donations) unless min_lifetime_donations.blank?
    people = people.where("people.lifetime_donations <= ?", max_lifetime_donations) unless max_lifetime_donations.blank?
    people
  end
end
