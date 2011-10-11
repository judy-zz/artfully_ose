class StiForActions < ActiveRecord::Migration
  def self.up
    change_table(:actions) do |t|
      t.remove :action_type
      t.remove :action_subtype
      t.string :type
    end
  end

  def self.down
    change_table(:actions) do |t|
      t.string :action_type
      t.string :action_subtype
      t.remove :type
    end
  end
end
