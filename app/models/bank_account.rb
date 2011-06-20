class BankAccount < ActiveRecord::Base
  belongs_to :organization

  validates :account_type,    :presence => true, :inclusion => { :in => [ "Business Checking", "Personal Checking", "Personal Savings"] }
  validates :routing_number,  :presence => true, :length => { :is => 9 }
  validates :number,          :presence => true, :length => { :is => 20 }

  validates :name,    :presence => true, :length => { :maximum => 50 }
  validates :address, :presence => true, :length => { :maximum => 100 }
  validates :city,    :presence => true, :length => { :maximum => 50 }
  validates :state,   :presence => true, :length => { :maximum => 2 }
  validates :zip,     :presence => true, :numericality => true, :length => { :is => 5 }
  validates :phone,   :presence => true, :length => { :is => 12 }, :format => { :with => /^\d{3}-\d{3}-\d{4}$/ }

  def account_information
    {
      :routing_number => routing_number,
      :number         => number,
      :account_type   => account_type
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
