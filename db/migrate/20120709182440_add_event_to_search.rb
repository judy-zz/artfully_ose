class AddEventToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :event_id, :integer
  end
end
