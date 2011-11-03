class AddSectionIdToTicket < ActiveRecord::Migration
  def self.up
    remove_column :tickets, :section
    add_column :tickets, :section_id, :integer
  end

  def self.down
    remove_column :tickets, :section_id
    add_column :tickets, :section, :integer
  end
end
