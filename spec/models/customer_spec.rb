require 'spec_helper'

describe Athena::Customer do
  subject { Factory(:customer) }

  %w( firstName lastName phone email ).each do |attribute|
    it { should respond_to attribute.underscore }
    it { should respond_to attribute.underscore + '=' }
  end

  %w( firstName lastName email ).each do |attribute|
    it "should not be valid if #{attribute.underscore} is blank" do
      subject = Factory(:customer, attribute.underscore => nil)
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
      @customer = Athena::Customer.find(1)

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

    it "should issue a POST when creating a new Athena::Customer" do
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
end
