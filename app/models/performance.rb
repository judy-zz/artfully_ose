class Performance < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :title, :venue, :performed_on
end
