require 'spec_helper'

describe AthenaCustomer do
  subject { Factory(:customer) }


  %w( first_name last_name phone email ).each do |attribute|
    it { should respond_to attribute }
    it { should respond_to attribute + '=' }
  end

  %w( first_name last_name email ).each do |attribute|
    it "should not be valid if #{attribute} is blank" do
      subject = Factory(:customer, attribute => nil)
      subject.should_not be_valid
      subject.errors.size.should == 1
    end
  end

  describe "#encode" do
    subject { Factory(:customer).encode }
    %w( firstName lastName phone email ).each do |attribute|
      it { should match(attribute) }
    end
  end

  describe "#find" do
    it "should find the customer by id" do
      FakeWeb.register_uri(:get, "http://localhost/payments/customers/1.json", :status => "200", :body => Factory(:customer, :id => 1).encode)
      @customer = AthenaCustomer.find(1)

      FakeWeb.last_request.method.should == "GET"
      FakeWeb.last_request.path.should == "/payments/customers/1.json"
    end
  end

  describe "#save" do
    it "should issue a PUT when updating a customer" do
      @customer = Factory(:customer, :id => "1")
      FakeWeb.register_uri(:put, "http://localhost/payments/customers/#{@customer.id}.json", :status => "200")
      @customer.save

      FakeWeb.last_request.method.should == "PUT"
      FakeWeb.last_request.path.should == "/payments/customers/#{@customer.id}.json"
    end

    it "should issue a POST when creating a new AthenaCustomer" do
      FakeWeb.register_uri(:post, "http://localhost/payments/customers/.json", :status => "200")
      @customer = Factory.create(:customer)

      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == "/payments/customers/.json"
    end
  end

  describe "#destroy" do
    it "should issue a DELETE when destroying a customer" do
      @customer = Factory(:customer, :id => "1")
      FakeWeb.register_uri(:delete, "http://localhost/payments/customers/#{@customer.id}.json", :status => "204")
      @customer.destroy

      FakeWeb.last_request.method.should == "DELETE"
      FakeWeb.last_request.path.should == "/payments/customers/#{@customer.id}.json"
    end
  end

  describe "#credit_cards" do
    it { should respond_to :credit_cards }
    it { should respond_to :credit_cards= }

    it "should create AthenaCreditCards when decoding the remote resource" do
      customer = Factory(:customer_with_id)
      customer.credit_cards << Factory(:credit_card)
      FakeWeb.register_uri(:get, "http://localhost/payments/customers/#{customer.id}.json", :status => 200, :body => customer.encode)

      remote = AthenaCustomer.find(customer.id)
      remote.credit_cards.should have(1).things
      remote.credit_cards.each do |credit_card|
        credit_card.kind_of?(AthenaCreditCard).should be_true
      end
    end
  end
end