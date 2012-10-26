class Discount < ActiveRecord::Base
  attr_accessible :active, :code, :promotion_type, :event, :organization, :creator

  belongs_to :event
  belongs_to :organization
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"

  validates_presence_of :active, :code, :promotion_type, :event, :organization, :creator
  validates :code, :length => { :minimum => 5, :maximum => 20 }
  
  serialize :properties

  before_validation :set_organization

  def set_organization
    self.organization ||= self.event.organization
  end
end
