class ImportError < ActiveRecord::Base

  attr_accessible :error_message
  belongs_to :import

  serialize :row_data

end
