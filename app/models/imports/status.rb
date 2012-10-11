module Imports
  module Status
    # Import status transitions:
    #   pending -> approved -> imported
    
    def self.included(base)
      base.class_eval do
        attr_accessible :status
      end
    end
    
    
    def caching!
      self.update_attributes(:status => "caching")
      Delayed::Job.enqueue self
    end

    def pending!
      self.update_attributes(:status => "pending")
    end

    def approve!
      self.update_attributes!(:status => "approved")
      Delayed::Job.enqueue self
    end

    def importing!
      self.update_attributes!(:status => "importing")
    end

    def imported!
      self.update_attributes!(:status => "imported")
    end

    def failed!
      self.update_attributes!(:status => "failed")
    end

    def failed?
      self.status == "failed"
    end
  end
end