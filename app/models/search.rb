class Search < ActiveRecord::Base
  attr_accessible :zip, :state, :event_id,
                  :min_lifetime_value, :max_lifetime_value,
                  :min_donations_amount, :max_donations_amount,
                  :min_donations_date, :max_donations_date
  belongs_to :organization
  belongs_to :event
  validates_presence_of :organization_id

  def people
    @people ||= find_people
  end

  private

  def find_people
    column_names = Person.column_names.collect {|cn| "people.#{cn}" }

    people = Person.where(organization_id: organization_id)
    people = people.joins(:address) unless zip.blank? && state.blank?
    people = people.joins(tickets: {show: :event}).where("events.id" => event_id) unless event_id.blank?
    people = people.where("addresses.zip" => zip) unless zip.blank?
    people = people.where("addresses.state" => state) unless state.blank?
    people = people.where("people.lifetime_value >= ?", min_lifetime_value) unless min_lifetime_value.blank?
    people = people.where("people.lifetime_value <= ?", max_lifetime_value) unless max_lifetime_value.blank?
    if min_donations_date.blank? && max_donations_date.blank?
      people = people.where("people.lifetime_donations >= ?", min_donations_amount) unless min_donations_amount.blank?
      people = people.where("people.lifetime_donations <= ?", max_donations_amount) unless max_donations_amount.blank?
    elsif ! min_donations_amount.blank? || ! max_donations_amount.blank?
      people = people.joins(:orders => :items)
      people = people.where("orders.created_at >= ?", min_donations_date) unless min_donations_date.blank?
      people = people.where("orders.created_at <= ?", max_donations_date) unless max_donations_date.blank?
      people = people.where("items.product_type = 'Donation'")
      people = people.group("people.id")
      people = people.select(column_names + ["SUM(items.price) AS total_donations"])
      people = people.having("total_donations >= ?", min_donations_amount) unless min_donations_amount.blank?
      people = people.having("total_donations <= ?", max_donations_amount) unless max_donations_amount.blank?
    end
    people
  end
end

# puts Person.joins(:orders => :items).sum("items.price")