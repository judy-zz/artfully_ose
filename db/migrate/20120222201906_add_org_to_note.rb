class AddOrgToNote < ActiveRecord::Migration
  def self.up
    add_column    :notes, :organization_id,  :integer
  end

  def self.down
    remove_column    :notes, :organization_id
  end
end
