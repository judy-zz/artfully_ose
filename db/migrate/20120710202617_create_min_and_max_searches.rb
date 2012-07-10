class CreateMinAndMaxSearches < ActiveRecord::Migration
  def change
    rename_column :searches, :lifetime_value, :min_lifetime_value
    rename_column :searches, :lifetime_donations, :min_lifetime_donations
    add_column :searches, :max_lifetime_value, :integer
    add_column :searches, :max_lifetime_donations, :integer
  end
end
