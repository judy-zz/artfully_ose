class AddNewsletterEmailsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :newsletter_emails, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :newsletter_emails
  end
end
