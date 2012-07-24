class AddTaggingToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :tagging, :string
  end
end
