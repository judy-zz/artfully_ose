class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
        t.belongs_to :person
        t.belongs_to :user
        t.string :type
        t.text :text
        t.timestamps
        t.datetime :occurred_at
    end
  end

  def self.down
    drop_table :notes
  end
end
