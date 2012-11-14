module Imports
  module Validations  
    def valid_date?(date_str)
      begin
        DateTime.parse(date_str)
      rescue
        raise Import::RowError, "Invalid date: #{date_str}"
      end    
      true
    end  
    
    #
    # Amount should be a string.  Will throw a RowError unless amount_str is all numeric with one dot and two digits after the dot
    #
    def valid_amount?(amount_str)
      if amount_str.match(/^\d+??(?:\.\d{0,2})?$/).nil?
        raise Import::RowError, "Invalid amount: #{amount_str}  Please input numbers and decimal points only, no currency symbols or other characters."
      end
    end
  end
end