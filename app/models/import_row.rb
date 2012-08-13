class ImportRow < ActiveRecord::Base
  attr_accessible :content
  belongs_to :import

  validates_presence_of :import
  validates_associated :import
  validates_presence_of :content

  serialize :content

end
