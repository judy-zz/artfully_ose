class CreateImports < ActiveRecord::Migration
  def self.up
    create_table :imports do |t|
      t.references :user
      t.string :s3_bucket
      t.string :s3_key
      t.string :s3_etag

      t.timestamps
    end
  end

  def self.down
    drop_table :imports
  end
end
