class Segment < ActiveRecord::Base
  attr_accessible :organization, :search, :name

  belongs_to :organization
  belongs_to :search

  validates_presence_of :organization_id
  validates_presence_of :search_id
  validates :name, :presence => true, :length => { :maximum => 128 }

  delegate :length, :to => :people

  def people
    @people ||= Person.search_index(terms, organization)
  end
end
