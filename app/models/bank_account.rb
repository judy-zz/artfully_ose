class BankAccount < ActiveRecord::Base
  belongs_to :organization

  before_validation :clean_phone

  ACCOUNT_TYPES = ["Business Checking", "Personal Checking", "Personal Savings"].freeze

  validates :routing_number,  :presence => true, :length => { :is => 9 }
  validates :number,          :presence => true
  validates :account_type,    :inclusion => { :in => ACCOUNT_TYPES }

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

  def clean_phone
    self.phone = phone.gsub(/\D/,"").insert(3,"-").insert(-5, "-") unless phone.blank?
  end

end
