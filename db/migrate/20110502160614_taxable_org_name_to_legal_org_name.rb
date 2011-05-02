class TaxableOrgNameToLegalOrgName < ActiveRecord::Migration
  def self.up
    rename_column :organizations, :taxable_organization_name, :legal_organization_name
  end

  def self.down
    rename_column :organizations, :legal_organization_name, :taxable_organization_name
  end
end
