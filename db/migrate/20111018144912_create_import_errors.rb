class CreateImportErrors < ActiveRecord::Migration
  def self.up
    create_table :import_errors do |t|
      t.references :import
      t.text :row_data
      t.text :error_message

      t.timestamps
    end
  end

  def self.down
    drop_table :import_errors
  end
end
