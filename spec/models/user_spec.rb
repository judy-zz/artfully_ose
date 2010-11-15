require 'spec_helper'

describe User do

  it "should save when valid" do
    @user = Factory.build(:user)
    @user.save.should be_true
  end

  it "should be valid with a valid email address" do
    @user = Factory.build(:user, :email => "example@example.com")
    @user.should be_valid
  end

  it "should validate the format of the email address" do
    @user = Factory.build(:user, :email => "example")
    @user.should be_invalid
  end

  describe "#customer" do
    subject { Factory(:user) }

    it { should respond_to(:customer_id) }
    it { should respond_to(:customer) }

    it "should fetch the remote customer record" do
      @customer = Factory(:customer, :id => 1)
      subject.customer_id = @customer.id
      FakeWeb.register_uri(:get, "http://localhost/payments/customers/#{@customer.id}.json", :status => 200, :body => @customer.encode)
      subject.customer.should eq(@customer)
    end

    it "should not make a request if the customer_id is not set" do
      @user = Factory(:user, :customer_id => nil)
      subject.customer.should be_nil
    end

    it "should set the customer id to nil if the remote resource no longer has it" do
      subject.customer_id = 1
      FakeWeb.register_uri(:get, "http://localhost/payments/customers/1.json", :status => 404)
      subject.customer.should be_nil
    end
  end

  describe "with roles" do
    before(:each) do
      @user = Factory(:user)
    end

    it { should respond_to(:roles) }
    it { should respond_to(:has_role?) }

    describe "#has_role?" do
      it "admin should return true when the user is a admin" do
        @user = Factory(:admin)
        @user.should have_role :admin
      end

      it "producer should return true when the user is a producer" do
        @user = Factory(:producer)
        @user.should have_role :producer
      end

      it "patron should return true when the user is a patron" do
        @user = Factory(:patron)
        @user.should have_role :patron
      end
    end

    it "#to_producer!" do
      @user.to_producer!
      @user.roles.should include(Role.producer)
    end

  end
end
