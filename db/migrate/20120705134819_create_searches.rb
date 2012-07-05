class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.integer :organization_id
      t.string :zip

      t.timestamps
    end
  end
end
