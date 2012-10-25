module Imports
  module Rollback  
    def items
      items = []
      ImportedOrder.where(:import_id => self.id).all.collect { |o| items = items + o.items.all }
      items
    end
  
    def actions
      Action.where(:import_id => self.id).all
    end
  
    def rollback_actions
      actions.each { |action| action.destroy }
    end
  
    def rollback_items
      items.each { |i| i.destroy }
    end
  
    def rollback_orders
      rollback_items
      rollback_actions
      Order.where(:import_id => self.id).all.each {|o| o.destroy}
    end
  
    def rollback_people
      Person.where(:import_id => self.id).all.each {|p| p.destroy}
    end
  end
end