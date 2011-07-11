class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.string :name
      t.string :time_zone
      t.string :legal_organization_name
      t.string :ein
      t.string :fa_member_id
      t.string :fa_project_id
      t.string :website
      t.timestamps
    end
  end

  def self.down
    drop_table :organizations
  end
end
