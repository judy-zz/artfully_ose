class AddStatusToImports < ActiveRecord::Migration

  def self.up
    add_column :imports, :status, :string, :default => "pending"
  end

  def self.down
    remove_column :imports, :status
  end

end
