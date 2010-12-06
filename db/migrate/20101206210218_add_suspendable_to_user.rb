class AddSuspendableToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      # t.suspendable # Currently broken?
      t.datetime :suspended_at
      t.string :suspension_reason
    end
  end

  def self.down
    remove_column :suspended_at, :suspension_reason
  end
end
