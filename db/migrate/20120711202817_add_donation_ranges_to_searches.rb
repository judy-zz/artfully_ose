class AddDonationRangesToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :min_donations_date, :datetime
    add_column :searches, :max_donations_date, :datetime
    rename_column :searches, :min_lifetime_donations, :min_donations_amount
    rename_column :searches, :max_lifetime_donations, :max_donations_amount
  end
end
