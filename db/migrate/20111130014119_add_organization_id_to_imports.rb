class AddOrganizationIdToImports < ActiveRecord::Migration

  def self.up
    add_column :imports, :organization_id, :integer

    execute <<-SQL.strip.gsub(/\s+/x, " ")
      UPDATE imports INNER JOIN memberships
      ON imports.user_id=memberships.user_id
      SET imports.organization_id=memberships.organization_id
    SQL
  end

  def self.down
    remove_column :imports, :organization_id
  end

end
