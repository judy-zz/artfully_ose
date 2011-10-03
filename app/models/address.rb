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
end