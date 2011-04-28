require 'spec_helper'

describe FA::Session do
  let(:user) { Factory(:fa_user) }
  subject { FA::Session.new(:user => user) }

  before(:each) do
    FakeWeb.register_uri(:post, "http://api.fracturedatlas.org/sessions.xml", :body => "")
  end

  describe ".authenticate" do
    it "creates a new session object" do
      FA::Session.authenticate(user).should be_an_instance_of(FA::Session)
    end

    it "attempts to authenticate the user" do
      FA::Session.authenticate(user);
      FakeWeb.last_request.method.should eq "POST"
      FakeWeb.last_request.path.should eq "/sessions.xml"
    end
  end

  describe "#authenticate" do
    it "attempts to authenticate the user" do
      subject.authenticate
      FakeWeb.last_request.method.should eq "POST"
      FakeWeb.last_request.path.should eq "/sessions.xml"
    end
  end

  describe "#encode" do
    it "includes a user node with the email and password set" do
      subject.authenticate
      expected_body = { :user => { :email => user.email, :password => user.password } }.to_xml(:root => :session)
      FakeWeb.last_request.body.should eq expected_body
    end
  end

  describe "#authenticated?" do
    context "with valid credentials" do
      it "is authenticated" do
        subject.authenticate
        subject.should be_authenticated
      end
    end

    context "with invalid credentials" do
      it "is not authenticated" do
        FakeWeb.register_uri(:post, "http://api.fracturedatlas.org/sessions.xml", :status => 403)
        subject.authenticate
        should_not be_authenticated
      end
    end
  end
end
