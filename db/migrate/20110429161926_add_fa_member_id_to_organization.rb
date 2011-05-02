class AddFaMemberIdToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :fa_member_id, :string
  end

  def self.down
    remove_column :organizations, :fa_member_id
  end
end
