require 'spec_helper'

describe User do

  it "should save when valid" do
    @user = Factory.build(:user)
    @user.save
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

    it "should list Producer as valid role" do
      User.valid_roles.should include(:producer)
    end

    it "should allow for assignment of a valid role" do
      @user.roles = [:producer]
      @user.roles.should include(:producer)
    end

    it "should allow for addtional roles to be added" do
      @user.roles << :producer
      @user.roles.should include(:producer)
    end
  end
end
