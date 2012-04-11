class CreateAdminMessages < ActiveRecord::Migration
  def self.up
    create_table :admin_messages do |t|
      t.text :message
      t.date :starts_on
      t.date :ends_on

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_messages
  end
end
