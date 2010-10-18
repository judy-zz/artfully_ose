require 'spec_helper'

describe Transaction do
  before(:each) do
    FakeWeb.allow_net_connect = false
    Transaction.site = 'http://localhost'
  end

  describe "attributes" do
    before(:each) do
      @transaction = Factory(:transaction)
    end

    it "should include tickets" do
      @transaction.respond_to?(:tickets).should be_true
    end

    it "should include lockExpires" do
      @transaction.respond_to?(:lockExpires).should be_true
    end

    it "should include lockedByApi" do
      @transaction.respond_to?(:lockedByApi).should be_true
    end

    it "should include lockedByIp" do
      @transaction.respond_to?(:lockedByIp).should be_true
    end

    it "should include status" do
      @transaction.respond_to?(:status).should be_true
    end
  end

  describe "creation with Tickets" do
    it "should accept an array of ticket ids" do
      pending
    end

    it "should allow for tickets to be appended via tickets<<" do
      pending
    end
  end
end
