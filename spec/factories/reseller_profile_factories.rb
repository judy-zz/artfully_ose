Factory.define(:reseller_profile) do |f|
  f.organization  { Factory(:organization_with_reselling) }
  f.fee           { 500 }
  f.url           { "http://www.example.com" }
end
