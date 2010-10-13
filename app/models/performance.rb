class Performance < ActiveRecord::Base
  validates_presence_of :title, :venue, :performed_on
end
