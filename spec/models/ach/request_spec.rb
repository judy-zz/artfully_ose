require 'spec_helper'

describe ACH::Request do
  let(:customer)    { Factory(:ach_customer) }
  let(:account)     { Factory(:ach_account) }
  let(:transaction) { ACH::Transaction.new(123400, "Test Transaction") }
  subject { ACH::Request.new(transaction, customer, account) }

  describe ".for" do
    let(:recipient) { Factory(:bank_account) }

    it "creates a new request with the amount set" do
      ACH::Request.for(2500, recipient, "memo").transaction.amount.should eq "25.00"
    end

    it "uses the recipient to set up the customer" do
      ACH::Request.for(2500, recipient, "memo").transaction.amount.should eq "25.00"
    end

    it "uses the account information to set up the account" do
      ACH::Request.for(2500, recipient, "memo").transaction.amount.should eq "25.00"
    end
  end

  describe "#new" do
    it "should store a reference to the required information" do
      subject.customer.should eq customer
      subject.account.should eq account
      subject.transaction.should eq transaction
    end
  end

  describe "#query" do
    it "should join the seralized hashes from transaction, customer, account" do
      query_hashes = [ transaction, customer, account ].collect(&:serializable_hash).reduce(:merge)
      subject.query.should eq ACH::Request::CREDENTIALS.merge(query_hashes)
    end
  end

  describe "#submit" do
    it "submits a GET request to First ACH" do
      FakeWeb.register_uri(:get, %r|https://demo.firstach.com/https/TransRequest\.asp?.*|, :body => "")
      subject.submit
      FakeWeb.last_request.method.should == "GET"
    end
  end
end
