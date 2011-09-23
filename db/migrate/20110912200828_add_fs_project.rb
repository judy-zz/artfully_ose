class AddFsProject < ActiveRecord::Migration
  def self.up
    create_table :fiscally_sponsored_projects do |table|
      table.string    :fs_project_id
      table.string    :fa_member_id
      table.string    :name                    
      table.string    :category                
      table.text      :profile                         
      table.string    :website                     
      table.datetime  :applied_on                      
      table.string    :status              
      table.integer   :organization_id        
      table.timestamps
    end    
    
    remove_column :organizations, :fa_project_id
  end

  def self.down
  end
end
