Factory.define :address, :default_strategy => :build do |a|
  a.first_name  "First"
  a.last_name "Last"
  a.company "Company"
  a.street_address1 "Street Address"
  a.street_address2 "Apt 1"
  a.city "City"
  a.state "State"
  a.postal_code "12345"
  a.country "Country"
end
