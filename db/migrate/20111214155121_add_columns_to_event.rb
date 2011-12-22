class AddColumnsToEvent < ActiveRecord::Migration
  def self.up
    add_column    :events, :contact_phone,  :string
    add_column    :events, :contact_email,  :string
    add_column    :events, :description,    :text
    add_column    :events, :venue_id,       :integer
    rename_column :events, :venue,          :venue_name    
  end

  def self.down
    remove_column :events, :contact_phone
    remove_column :events, :contact_email
    remove_column :events, :description
    remove_column :events, :venue_id
    rename_column :events, :venue_name, :venue 
  end
end
