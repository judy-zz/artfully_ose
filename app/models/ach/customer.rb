class ACH::Customer
  attr_accessor :id, :name, :address, :city, :state, :zip, :phone

  MAPPING = {
    :id       => "Customer_ID",
    :name     => "Customer_Name",
    :address  => "Customer_Address",
    :city     => "Customer_City",
    :state    => "Customer_State",
    :zip      => "Customer_Zip",
    :phone    => "Customer_Phone"
  }.freeze

  def serialize
    MAPPING.collect{ |method, key| "#{key}=#{send(method)}" }.join("&")
  end
end