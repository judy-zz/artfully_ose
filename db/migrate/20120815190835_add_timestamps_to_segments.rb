class AddTimestampsToSegments < ActiveRecord::Migration
  def change
    change_table :segments do |t|
      t.timestamps
    end
  end
end
