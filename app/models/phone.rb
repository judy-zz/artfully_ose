class Phone < ActiveRecord::Base
  belongs_to :person

  def self.kinds
    [ "Work", "Home", "Cell", "Fax" ]
  end
end