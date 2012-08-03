Factory.define :donation do |d|
  d.amount 1000
  d.association :organization
end

Factory.define :sponsored_donation, :parent => :donation do |d|
  d.after_create do |donation|
    donation.organization.fiscally_sponsored_project = FiscallySponsoredProject.new
    donation.organization.fiscally_sponsored_project.fs_project_id = 1
    donation.organization.save
  end
end