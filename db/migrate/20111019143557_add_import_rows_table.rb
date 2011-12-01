class AddImportRowsTable < ActiveRecord::Migration

  def self.up
    create_table :import_rows do |t|
      t.references :import
      t.text :content
    end
    add_column :imports, :import_headers, :text
  end

  def self.down
    remove_column :imports, :import_headers
    drop_table :import_rows
  end

end
