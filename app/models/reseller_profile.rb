class ResellerProfile < ActiveRecord::Base

  FEE_OPTIONS = { "$0.00" => 0, "$0.50" => 50, "$1.00" => 100, "$2.00" => 200 }

  belongs_to :organization
  has_many :ticket_offers

end
