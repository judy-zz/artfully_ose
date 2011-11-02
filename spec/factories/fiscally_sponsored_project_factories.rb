Factory.sequence :project_id do |id|
  id
end

Factory.sequence :member_id do |id|
  id
end

Factory.define :fiscally_sponsored_project do |fsp|
  fsp.fs_project_id { Factory.next(:project_id) }
  fsp.fa_member_id { Factory.next(:member_id) }
  fsp.name "Test Project"
  fsp.category "Category"
  fsp.profile "Profile"
  fsp.website "http://www.test.com"
  fsp.applied_on { Time.now - 1.year}
  fsp.status "Active"
  fsp.updated_at { Time.now }
end