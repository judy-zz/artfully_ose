class Address < AthenaResource::Base
  self.site = Artfully::Application.config.people_site

  schema do
    attribute 'address1',  :string
    attribute 'address2',  :string
    attribute 'city',      :string
    attribute 'state',     :string
    attribute 'zip',       :string
    attribute 'country',   :string

    attribute 'person_id', :string
  end

  validates :person_id, :presence => true

  def address
    "#{address1} #{address2}"
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
