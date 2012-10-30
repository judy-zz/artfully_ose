module OhNoes
  module Destroy
    
    def self.included(base)
      base.class_eval do
        default_scope where(:deleted_at => nil)
      end
    end
  
    #
    # options:
    # :with_prejudice => true, will not check destroyable?
    #
    delegate :destroy!, :to => :destroy
    def destroy(options = {})
      return false unless destroyable? && !options[:with_prejudice]
      run_callbacks :destroy do
        update_attribute(:deleted_at, Time.now)
      end
    end
    
    def destroyable?
      true
    end
  
  end
end