class AddOrganizationIdToImports < ActiveRecord::Migration

  def self.up
    add_column :imports, :organization_id, :integer
  end

  def self.down
    remove_column :imports, :organization_id
  end

end
