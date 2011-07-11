Factory.define :donation do |d|
  d.amount 1000
  d.association :organization
end

Factory.define :sponsored_donation, :parent => :donation do |d|
  d.after_create do |donation|
    donation.organization.update_attribute(:fa_project_id, 1)
  end
end