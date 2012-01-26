Factory.define(:reseller_profile) do |f|
  f.organization { Factory(:organization_with_reselling) }
end
