class SetCreatedAtOnOrders < ActiveRecord::Migration
  def up
    a = Action.arel_table
    Action.where(a[:subtype].matches('Donation (%')).each do |action|
      if action.subject.nil?
        puts "ACTION #{action.id} has no order"
      else
        puts "Updating ORDER #{action.subject.id} from ACTION #{action.id}"
        action.subject.update_attribute(:created_at, action.occurred_at)
      end
    end
  end

  def down
    #raise ActiveRecord::IrreversibleMigration
  end
end
