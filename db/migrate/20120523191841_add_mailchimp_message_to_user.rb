class AddMailchimpMessageToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :mailchimp_message, :string
  end

  def self.down
    remove_column :users, :mailchimp_message
  end
end
