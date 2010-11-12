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
