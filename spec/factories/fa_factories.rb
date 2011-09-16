Factory.define :fa_user, :class => FA::User, :default_strategy => :build do |f|
  f.email "user@fracturedatlas.org"
  f.username "user"
  f.password "password"
end

Factory.define :fa_user_with_member_id, :class => FA::User, :default_strategy => :build do |f|
  f.email "user@fracturedatlas.org"
  f.username "user"
  f.password "password"
  f.member_id 44539
end

Factory.define :fa_donor, :class => FA::Donor, :default_strategy => :build do |donor|
  donor.first_name "Jim"
  donor.last_name "Mississippi"
  donor.email "jim@mississippi.org"
  donor.anonymous "Yes"
end

Factory.define :fa_donation, :class => FA::Donation, :default_strategy => :build do |d|
  d.amount "40.00"
  d.nongift "10.00"
  d.fs_project_id "10000"
  d.date "2010-08-27"
  d.check_no "3"
  d.is_noncash "1"
  d.reversed_at "2010-08-27 00:00:00"
  d.reversed_note "Note"
  d.fs_available_on "2010-09-03"
  d.is_anonymous "1"
  
  d.donor Factory(:fa_donor)
end