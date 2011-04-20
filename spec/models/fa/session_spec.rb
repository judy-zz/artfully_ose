require 'spec_helper'

describe FA::Session do
  let(:email) { "test.user@test.com" }
  let(:password) { Digest::MD5.hexdigest("password") }
  subject { FA::Session.with_credentials(email, password) }

  before(:each) do
    FakeWeb.register_uri(:post, "http://api.fracturedatlas.org/sessions.xml", :body => "")
  end

  describe ".with_credentials" do
    it "creates a new session object" do
      FA::Session.with_credentials(email, password).should be_an_instance_of(FA::Session)
    end

    it "creates a new Session from the credentials" do
      subject.user.email.should eq email
      subject.user.password.should eq password
    end
  end

  describe ".authenticate" do
    it "creates a new session object" do
      FA::Session.authenticate(email, password).should be_an_instance_of(FA::Session)
    end

    it "attempts to authenticate the user" do
      FA::Session.authenticate(email, password);
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
      expected_body = { :user => { :email => email, :password => password } }.to_xml(:root => :session)
      FA::Session.authenticate(email, password)
      FakeWeb.last_request.body.should eq expected_body
    end
  end

  describe "#authenticated?" do
    before(:each) do
      subject.authenticate
    end

    context "with valid authenticate credentials" do
      it { subject.should be_authenticated }
    end

    context "with invalid authenticate credentials" do
      it { should_not be_authenticated }
    end
  end
end
