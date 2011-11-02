class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table(:people) do |t|
      t.belongs_to      :organization
      t.string          :state
      t.string          :type
      t.string          :email           
      t.string          :first_name     
      t.string          :last_name      
      t.string          :company_name   
      t.string          :website      
      t.boolean         :dummy       
      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
