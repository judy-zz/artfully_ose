Factory.define :schema do |s|

end

Factory.sequence :id do |n|
  "#{n}"
end

Factory.define :ticket do |t|
  t.id Factory.next :id
end
