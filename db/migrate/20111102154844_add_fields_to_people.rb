class AddFieldsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :person_type,     :string
    add_column :people, :twitter_handle,  :string
    add_column :people, :facebook_url,    :string
    add_column :people, :linked_in_url,   :string
    add_column :people, :import_id,       :integer
  end

  def self.down
    remove_column :imports, :person_type
    remove_column :imports, :twitter_handle
    remove_column :imports, :facebook_url
    remove_column :imports, :linked_in_url
    remove_column :imports, :import_id
  end
end
