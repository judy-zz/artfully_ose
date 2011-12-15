class CreateVenues < ActiveRecord::Migration
  def self.up
    create_table  :venues
    add_column    :venues, :organization_id,    :integer
    add_column    :venues, :name,               :string
    add_column    :venues, :address1,           :string
    add_column    :venues, :address2,           :string
    add_column    :venues, :city,               :string
    add_column    :venues, :state,              :string
    add_column    :venues, :zip,                :string
    add_column    :venues, :country,            :string
    add_column    :venues, :time_zone,          :string
    add_column    :venues, :phone,              :string
    add_column    :venues, :lat,                :float
    add_column    :venues, :long,               :float
  end

  def self.down
    drop_table  :venues
  end
end
