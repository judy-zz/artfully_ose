class AddDonationKitTaxableOrgNameAndEin < ActiveRecord::Migration
  def self.up
    add_column :kits, :taxable_organization_name, :string
    add_column :kits, :ein, :string
  end

  def self.down
    remove_column :kits, :taxable_organization_name
    remove_column :kits, :ein
  end
end
