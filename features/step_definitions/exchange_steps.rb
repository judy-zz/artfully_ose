When /^I check the (\d+)st ticket for an exchange$/ do |pos|
  within(:xpath, "(//div[@id='exchanges']/form/ul/li)[#{pos.to_i}]") do
    check("items[]")
  end
end
