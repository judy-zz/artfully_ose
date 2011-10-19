class ImportError < ActiveRecord::Base

  belongs_to :import

  serialize :row_data

end
