class AddWebsiteToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :website, :string
  end

  def self.down
    drop_column :organiations, :website
  end
end
