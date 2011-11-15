class Address < ActiveRecord::Base
  belongs_to :person

  validates :person_id, :presence => true

  def address
    "#{address1} #{address2}"
  end
  
  def to_s
    "#{address1} #{address2} #{city} #{state} #{zip} #{country}"
  end

  def self.from_payment(payment)
    billing_address = payment.billing_address

    new({
      :address1 => billing_address.street_address1,
      :address2 => billing_address.street_address2,
      :city     => billing_address.city,
      :state    => billing_address.state,
      :zip      => billing_address.postal_code,
      :country  => billing_address.country
    })
  end
end
