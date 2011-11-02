class CreateActions < ActiveRecord::Migration
  def self.up
    create_table(:actions) do |t|
      t.belongs_to      :organization
      t.belongs_to      :person
      t.belongs_to      :user
      t.string          :action_type
      t.string          :action_subtype
      t.datetime        :occurred_at
      t.string          :details
      t.boolean         :starred
      t.integer         :dollar_amount   
      t.timestamps
    end
  end

  def self.down
    drop_table :actions
  end
end
