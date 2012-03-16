class AddImageToEvents < ActiveRecord::Migration

  def self.up
    add_column :events, :image_file_name, :string
    add_column :events, :image_content_type, :string
    add_column :events, :image_file_size, :integer
  end

  def self.down
    remove_column :events, :image_file_size
    remove_column :events, :image_content_type
    remove_column :events, :image_file_name
  end

end
