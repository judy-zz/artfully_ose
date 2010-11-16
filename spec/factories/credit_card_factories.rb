Factory.sequence :number do
  %w( 4111111111111111
      4005519200000004
      4009348888881881
      4012000033330026
      4012000077777777
      4012888888881881
      4217651111111119
      4500600000000061
      5555555555554444
      378282246310005
      371449635398431
      6011111111111117
      3530111333300000 ).rand
end

Factory.define :credit_card, :class => Athena::CreditCard, :default_strategy => :build do |cc|
  cc.card_number { Factory.next(:number) }
  cc.expiration_date { Date.today }
  cc.cardholder_name { Faker::Name.name }
  cc.cvv "123"
end

#Factory.define :invalid_credit_card
