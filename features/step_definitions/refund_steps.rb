Given /^I check the (\d+)(?:st|nd|rd|th) ticket for a refund$/ do |pos|
  within(:xpath, "(//table/tbody/tr)[#{pos.to_i}]") do
    check("items[]")
  end
end

