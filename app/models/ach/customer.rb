class ACH::Customer
  include ACH::Serialization

  attr_accessor :id, :name, :address, :city, :state, :zip, :phone

  def initialize(attributes = {})
    # TODO: Use organization to set this information
    self.id      = attributes[:id]
    self.name    = attributes[:name]
    self.address = attributes[:address]
    self.city    = attributes[:city]
    self.state   = attributes[:state]
    self.zip     = attributes[:zip]
    self.phone   = attributes[:phone]
  end

  MAPPING = {
    :id       => "Customer_ID",
    :name     => "Customer_Name",
    :address  => "Customer_Address",
    :city     => "Customer_City",
    :state    => "Customer_State",
    :zip      => "Customer_Zip",
    :phone    => "Customer_Phone"
  }.freeze
end