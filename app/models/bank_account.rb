class BankAccount < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :routing_number, :number, :account_type
  validates_presence_of :name, :address, :city, :state, :zip, :phone

  def account_information
    {
      :routing_number => routing_number,
      :number         => number,
      :account_type           => account_type
    }
  end

  def customer_information
    {
      :id      => id,
      :name    => name,
      :address => address,
      :city    => city,
      :state   => state,
      :zip     => zip,
      :phone   => phone
    }
  end
end
