class Segment < ActiveRecord::Base
  attr_accessible :terms
  belongs_to :organization

  validates :organization_id, :presence => true
  validates :name, :presence => true, :length => { :maximum => 128 }

  delegate :length, :to => :people

  def people
    @people ||= Person.search_index(terms, organization)
  end
end