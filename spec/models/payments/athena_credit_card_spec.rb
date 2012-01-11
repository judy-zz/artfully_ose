require 'spec_helper'

describe AthenaCreditCard do
  subject { Factory(:credit_card) }

  %w( cardNumber expirationDate cardholderName cvv ).each do |attribute|
    it { should respond_to attribute.underscore }
    it { should respond_to attribute.underscore + '=' }
  end

  describe "parsing track data" do
    it "should parse swiped track data" do
      cc = AthenaCreditCard.new({:card_number => '%B0123456789012345^MOORE/GARY S^1409101000000000000000000000000?;0123456789012345=15021010000000000869?'})
      cc.parse_card_number
      cc.card_number.should eq '0123456789012345'
      cc.cardholder_name.should eq 'GARY S MOORE'
      cc.expirationd_date.should eq '09/2014'
    end
  end
  
  it "should not be valid with a credit card with letters" do
    p subject.new_record?
    subject.card_number << "A"
    subject.should_not be_valid
  end

  it "should not be valid with an invalid credit card number" do
    subject.card_number = "1234123412341234"
    subject.should_not be_valid
  end

  it "should be valid with a credit card number that has spaces" do
    subject.card_number = "4111 111111111111"
    subject.should be_valid
  end

  it "should be valid with a credit card number that has dashes" do
    subject.card_number = "4111-1111-1111-1111"
    subject.should be_valid
  end

  describe "#encode" do
    subject { Factory(:credit_card).encode }
    %w( cardNumber expirationDate cardholderName cvv ).each do |attribute|
      it { should match(attribute) }
    end

    it "should use the MM/YY format when encoding the expiration date to JSON" do
      @card = Factory(:credit_card)
      @card.encode.should match(/\"expirationDate\":\"#{@card.expiration_date.strftime('%m\/%Y')}\"/)
    end

    it "should not include the credit card number when updating a card" do
      @card = Factory(:credit_card_with_id)
      FakeWeb.register_uri(:put, "http://localhost/payments/cards/#{@card.id}.json", :body => @card.encode)
      @card.save
      FakeWeb.last_request.body.should_not match /cardNumber/
    end
  end

  it "should parse the date into a Date object when fetching a remote resource" do
    card = Factory(:credit_card)
    FakeWeb.register_uri(:get, "http://localhost/payments/cards/#{card.id}.json", :body => card.encode)
    remote = AthenaCreditCard.find(card.id)
    remote.expiration_date.kind_of?(Date).should be_true
  end

  describe "#find" do
    it "should find the card by id" do
      FakeWeb.register_uri(:get, "http://localhost/payments/cards/1.json", :body => Factory(:credit_card, :id => 1).encode)
      @card = AthenaCreditCard.find(1)

      FakeWeb.last_request.method.should == "GET"
      FakeWeb.last_request.path.should == "/payments/cards/1.json"
    end
  end

  describe "#save" do
    it "should issue a PUT when updating a card" do
      @card = Factory(:credit_card, :id => "1")
      FakeWeb.register_uri(:put, "http://localhost/payments/cards/#{@card.id}.json", :body => @card.encode)
      @card.save

      FakeWeb.last_request.method.should == "PUT"
      FakeWeb.last_request.path.should == "/payments/cards/#{@card.id}.json"
    end

    it "should issue a POST when creating a new AthenaCreditCard" do
      FakeWeb.register_uri(:post, "http://localhost/payments/cards.json", :body => "{}")
      @card = Factory.create(:credit_card, :id => nil)

      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == "/payments/cards.json"
    end
  end

  describe "#destroy" do
    it "should issue a DELETE when destroying a card" do
      @card = Factory(:credit_card, :id => "1")
      FakeWeb.register_uri(:delete, "http://localhost/payments/cards/#{@card.id}.json", :status => "204")
      @card.destroy

      FakeWeb.last_request.method.should == "DELETE"
      FakeWeb.last_request.path.should == "/payments/cards/#{@card.id}.json"
    end
  end
end
