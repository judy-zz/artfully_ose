class Address < ActiveRecord::Base
  belongs_to :person

  validates :person_id, :presence => true

  def address
    "#{address1} #{address2}"
  end
  
  def to_s
    "#{address1} #{address2} #{city} #{state} #{zip} #{country}"
  end

  def is_same_as(addr)
    return address1.eql?(addr.address1) &&
           address2.eql?(addr.address2) &&
           city.eql?(addr.city) &&
           state.eql?(addr.state) &&
           zip.eql?(addr.zip) &&
           country.eql?(addr.country)
  end

  def self.from_payment(payment)
    if payment.respond_to? "billing_address"
      billing_address = payment.billing_address

      new({
        :address1 => billing_address.street_address1,
        :address2 => billing_address.street_address2,
        :city     => billing_address.city,
        :state    => billing_address.state,
        :zip      => billing_address.postal_code,
        :country  => billing_address.country
      })
    else
      nil
    end
  end

  def self.find_or_create(pers_id)
    find(pers_id) rescue Address.create(:person_id => pers_id)
  end

  def update_with_note?(person, user, address, time_zone, updated_by)
    old_addr = to_s()

    unless is_same_as(address)
      if update_attributes(address.attributes)
        update_attributes(address.attributes)
        extra = updated_by.nil? ? "" : " from #{updated_by}"
        person.notes.create({
          :person_id    => person.id,
          :occurred_at  => DateTime.now.in_time_zone(time_zone),
          :user         => user,
          :text         => "address updated#{extra}, old address was: (#{old_addr})" })
      else
        return false
      end
    end

    true
  end
end
