class AddCaptionToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :special_instructions_caption, :string, :default => 'Special Instructions'
    add_column :events, :show_special_instructions, :boolean, :default => false 
    
    add_column :orders, :special_instructions, :text
  end

  def self.down
    remove_column :events, :special_instructions_caption
    remove_column :events, :show_special_instructions
    
    remove_column :orders, :special_instructions
  end
end
