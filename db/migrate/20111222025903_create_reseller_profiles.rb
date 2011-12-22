class CreateResellerProfiles < ActiveRecord::Migration
  def self.up
    create_table :reseller_profiles do |t|
      t.references :organization
      t.text :url
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :reseller_profiles
  end
end
