class CreateMemberships < ActiveRecord::Migration
  def self.up
    remove_column :users, :organization_id

    create_table :memberships do |t|
      t.belongs_to :user
      t.belongs_to :organization
    end
  end

  def self.down
    drop_table :memberships
    add_column :users, :organization_id
  end
end
