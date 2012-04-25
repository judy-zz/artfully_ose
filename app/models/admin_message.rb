class AdminMessage < ActiveRecord::Base

  validates_presence_of :message
  validates_presence_of :starts_on, :ends_on

  scope :active, lambda { |time = Time.now| where "starts_on <= :date AND :date <= ends_on", date: time.to_date }

end
