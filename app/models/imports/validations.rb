module Imports
  module Validations  
    def valid_date?(date_str)
      
      if date_str.blank?
        raise Import::RowError, "Please include a date"
      end
      
      #Check for YYYY/
      if date_str.match(/^[0-9][0-9][0-9][0-9]\//).nil?
        raise Import::RowError, "Invalid date: #{date_str}  Make sure the date is in the format YEAR, MONTH, DAY (YYYY/MM/DD)."
      end
      
      begin
        DateTime.parse(date_str)
      rescue
        raise Import::RowError, "Invalid date: #{date_str}  Make sure the date is in the format YEAR, MONTH, DAY (YYYY/MM/DD)."
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