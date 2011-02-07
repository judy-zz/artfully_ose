Factory.define :donation do |d|
  d.amount 1000
  d.recipient { Factory(:athena_person_with_id) }
end