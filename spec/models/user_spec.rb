require 'spec_helper'

describe User do
  subject { FactoryGirl.build(:user) }

  it "should be valid with a valid email address" do
    subject.email = "example@example.com"
    subject.should be_valid
  end

  it "should validate the format of the email address" do
    subject.email = "example"
    subject.should be_invalid
  end

  describe "suspension" do
    it { should respond_to :suspended? }
    it { should respond_to :unsuspend! }
    it { should respond_to :suspend! }

    it "should not be active when suspended" do
      subject.suspend!
      subject.should_not be_active_for_authentication
    end

    it "should be active when it is unsuspended" do
      subject.unsuspend!
      subject.should be_active_for_authentication
    end

    it "should not remain suspended after unsuspension" do
      subject.suspend!
      subject.should be_suspended
      subject.unsuspend!
      subject.should_not be_suspended
    end
  end

  RSpec::Matchers.define :include_this_email do |expected|
    match do |actual|
      actual[:email_address].should eq expected
    end
  end

  describe "with regards to mailchimp, it" do
    before(:each) do
      Delayed::Worker.delay_jobs = false
    end
    
    it "should subscribe the user to mailchimp if they opted in" do
      @user = User.new({:email => Faker::Internet.email, :password => 'password', :newsletter_emails => true})
      Gibbon.any_instance.should_receive(:list_subscribe).with(include_this_email(@user.email)).and_return(true)
      @user.save
    end
    
    it "should store any error messages" do
      @user = User.new({:email => Faker::Internet.email, :password => 'password', :newsletter_emails => true})
      Gibbon.any_instance.should_receive(:list_subscribe).with(include_this_email(@user.email)).and_return({'error' => 'an error'})
      @user.save
      @user = User.find(@user.id)
      @user.mailchimp_message.should eq "an error"
    end
    
    it "should not subscribe the user if they did not opt in" do
      @user = User.new({:email => Faker::Internet.email, :password => 'password', :newsletter_emails => false})
      Gibbon.any_instance.should_not_receive(:list_subscribe)
      @user.save
    end
  end

  describe "organizations" do
    let(:organization) { FactoryGirl.build(:organization) }

    it { should respond_to :organizations }
    it { should respond_to :memberships }

    it "should return the first organization as the current organization" do
      subject.organizations << organization
      subject.current_organization.should eq organization
    end

    it "should return a new organization if the user does not belong to any" do
      subject.current_organization.should be_new_record
    end
  end
end
