class AthenaAddress < AthenaResource::Base
  self.site = Artfully::Application.config.payments_component

  schema do
    attribute 'first_name',      :string
    attribute 'last_name',       :string
    attribute 'company',        :string
    attribute 'street_address1', :string
    attribute 'street_address2', :string
    attribute 'city',           :string
    attribute 'state',          :string
    attribute 'postal_code',     :string
    attribute 'country',        :string
  end

  validates_presence_of :street_address1, :city, :state, :postal_code
end
