Factory.define :chart do |c|
  c.name 'Test Chart'
  c.is_template false
  c.association :organization
end

Factory.define :chart_with_sections, :parent => :chart do |c|
  c.after_create do |chart|
    chart.sections << Factory(:section)
  end
end

Factory.define :chart_template, :parent => :chart do |c|
  c.is_template true
end