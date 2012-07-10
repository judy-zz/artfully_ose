class AddLifetimeDonationsToPeopleAndSearches < ActiveRecord::Migration
  def change
    add_column :searches, :lifetime_donations, :integer
    add_column :people, :lifetime_donations, :integer, default: 0
  end
end
