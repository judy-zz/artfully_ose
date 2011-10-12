Factory.define :admin do |u|
  u.email { Faker::Internet.email }
  u.password 'password'
end

Factory.define :admin_stats do |s|
  s.users 0
  s.logged_in_more_than_once 0
  s.organizations 0
  s.fa_connected_orgs 0
  s.active_fafs_projects 0
  s.ticketing_kits 0
  s.donation_kits 0
  s.tickets 0
  s.tickets_sold 0
  s.donations 0
  s.fafs_donations 0
end