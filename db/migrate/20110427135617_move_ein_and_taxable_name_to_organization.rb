class MoveEinAndTaxableNameToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :taxable_organization_name, :string
    add_column :organizations, :ein, :string
    
    remove_column :kits, :taxable_organization_name
    remove_column :kits, :ein
  end

  def self.down
    remove_column :organizations, :taxable_organization_name
    remove_column :organizations, :ein

    add_column :kits, :taxable_organization_name, :string
    add_column :kits, :ein, :string
  end
end
