module Ext
  module Integrations
    module User
    end
    
    module Organization
      def connected?
        false
      end 
      
      def fsp
        nil
      end

      def has_active_fiscally_sponsored_project?
        false
      end

      def has_fiscally_sponsored_project?
        false
      end

      def refresh_active_fs_project
      end

      def items_sold_as_reseller_during(date_range)
        []
      end

      def name_for_donations
        self.name
      end
    end
  end
end