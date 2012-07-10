class AddLifetimeValueToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :lifetime_value, :integer
  end
end
