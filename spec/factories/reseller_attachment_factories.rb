Factory.define(:reseller_attachment) do |s|
  s.reseller_profile { Factory(:reseller_profile) }
  s.event { Factory(:event) }
end
