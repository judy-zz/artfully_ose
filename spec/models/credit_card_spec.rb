require 'spec_helper'

describe Athena::CreditCard do
  subject { Factory(:credit_card) }

  %w( cardNumber expirationDate cardholderName cvv ).each do |attribute|
    it { should respond_to attribute.underscore }
    it { should respond_to attribute.underscore + '=' }
  end

  it "should use the MM/YY format when encoding the expiration date to JSON" do
    @card = Factory(:credit_card)
    @card.to_json.should match(/\"expirationDate\":\"#{@card.expiration_date.strftime('%m\/%Y')}\"/)
  end

  describe "#encode" do
    subject { Factory(:credit_card).encode }
    %w( cardNumber expirationDate cardholderName cvv ).each do |attribute|
      it { should match(attribute) }
    end
  end

  describe "#find" do
    it "should find the card by id" do
      FakeWeb.register_uri(:get, "http://localhost/payments/cards/1.json", :status => "200", :body => Factory(:credit_card, :id => 1).encode)
      @card = Athena::CreditCard.find(1)

      FakeWeb.last_request.method.should == "GET"
      FakeWeb.last_request.path.should == "/payments/cards/1.json"
    end
  end

  describe "#save" do
    it "should issue a PUT when updating a card" do
      @card = Factory(:credit_card, :id => "1")
      FakeWeb.register_uri(:put, "http://localhost/payments/cards/#{@card.id}.json", :status => "200")
      @card.save

      FakeWeb.last_request.method.should == "PUT"
      FakeWeb.last_request.path.should == "/payments/cards/#{@card.id}.json"
    end

    it "should issue a POST when creating a new Athena::Ticket" do
      FakeWeb.register_uri(:post, "http://localhost/payments/cards/.json", :status => "200")
      @card = Factory.create(:credit_card)

      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == "/payments/cards/.json"
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
