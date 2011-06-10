require 'spec_helper'

describe ACH::Request do
  let(:customer)    { Factory(:ach_customer) }
  let(:account)     { Factory(:ach_account) }
  let(:transaction) { Factory(:ach_transaction) }
  subject { ACH::Request.new(transaction, customer, account) }

  describe "#new" do
    it "should store a reference to the required information" do
      subject.customer.should eq customer
      subject.account.should eq account
      subject.transaction.should eq transaction
    end
  end

  describe "#serialize" do
    it "should join the seralized hashes from transaction, customer, account" do
      subject.serialize.should match /#{transaction.serialize}/
      subject.serialize.should match /#{customer.serialize}/
      subject.serialize.should match /#{account.serialize}/
      subject.serialize.should eq [ transaction, customer, account ].collect(&:serialize).join("&")
    end
  end
end
