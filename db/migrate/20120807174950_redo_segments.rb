class RedoSegments < ActiveRecord::Migration
  def up
    create_table :segments, :force => true do |t|
      t.string  :name,            :null => false
      t.integer :organization_id, :null => false
      t.integer :search_id,       :null => false
    end
    add_index :segments, :organization_id
    add_index :segments, :search_id
  end

  def down
    create_table :segments, :force => true do |t|
      t.string  :name
      t.string  :terms
      t.integer :organization_id
    end
  end
end
