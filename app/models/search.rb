class Search < ActiveRecord::Base
  attr_accessible :zip, :state, :event_id, :tagging,
                  :min_lifetime_value, :max_lifetime_value,
                  :min_donations_amount, :max_donations_amount,
                  :min_donations_date, :max_donations_date
  belongs_to :organization
  belongs_to :event
  validates_presence_of :organization_id

  def length
    people.length
  end

  def people
    @people ||= find_people
  end

  def description
    conditions = []
    conditions << "bought tickets for #{event.name}" unless event_id.blank?
    if conditions.blank?
      return "All people."
    else
      return "People that #{conditions.to_sentence}."
    end
  end

  private

  def find_people
    column_names = Person.column_names.collect {|cn| "people.#{cn}" }

    people = Person.where(:organization_id => organization_id)
    people = people.order('lower(last_name) ASC')
    people = people.tagged_with(tagging) unless tagging.blank?
    people = people.joins(:address) unless zip.blank? && state.blank?
    people = people.joins(:tickets => {:show => :event}).where("events.id" => event_id) unless event_id.blank?
    people = people.where("addresses.zip" => zip) unless zip.blank?
    people = people.where("addresses.state" => state) unless state.blank?
    people = people.where("people.lifetime_value >= ?", min_lifetime_value * 100.0) unless min_lifetime_value.blank?
    people = people.where("people.lifetime_value <= ?", max_lifetime_value * 100.0) unless max_lifetime_value.blank?
    unless [min_donations_amount, max_donations_amount, min_donations_date, max_donations_date].all?(&:blank?)
      column_names << "SUM(items.price + items.nongift_amount) AS total_donations"
      people = people.joins(:orders => :items)
      people = people.where("orders.created_at >= ?", min_donations_date) unless min_donations_date.blank?
      people = people.where("orders.created_at <= ?", max_donations_date + 1.day) unless max_donations_date.blank?
      people = people.where("items.product_type = 'Donation'")
      people = people.group("people.id")
      if min_donations_amount.blank?
        people = people.having("total_donations >= 1")
      else
        people = people.having("total_donations >= ?", min_donations_amount * 100.0)
      end
      people = people.having("total_donations <= ?", max_donations_amount * 100.0) unless max_donations_amount.blank?
    end
    people.select(column_names).uniq
  end
end
