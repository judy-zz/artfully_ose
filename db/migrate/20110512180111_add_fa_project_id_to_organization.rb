class AddFaProjectIdToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :fa_project_id, :string
  end

  def self.down
    drop_column :organizations, :fa_project_id, :string
  end
end
