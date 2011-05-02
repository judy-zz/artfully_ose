require 'spec_helper'

describe FA::Session do
  let(:user) { Factory(:fa_user) }
  subject { FA::Session.new(:user => user) }

  before(:each) do
    id = 1
    body = { :session => { :user => { :membership_id => 1 } } }.to_xml
    FakeWeb.register_uri(:get, "http://api.fracturedatlas.org/sessions/#{id}.xml", :body => body)
    FakeWeb.register_uri(:post, "http://api.fracturedatlas.org/sessions.xml", :location => "http://api.fracturedatlas.org/sessions/#{id}.xml")
  end

  before(:each) do
    id = 1
    body = { :user => { :membership_id => 1 } }.to_xml
    FakeWeb.register_uri(:get, "http://api.fracturedatlas.org/sessions/#{id}.xml", :body => body)
    FakeWeb.register_uri(:post, "http://api.fracturedatlas.org/sessions.xml", :location => "http://api.fracturedatlas.org/sessions/#{id}.xml")
  end

  describe ".authenticate" do
    it "creates a new session object" do
      FA::Session.authenticate(user).should be_an_instance_of(FA::Session)
    end
  end

  describe "#authenticate" do
    it "attempts to authenticate the user" do
      subject.stub(:reload).and_return
      subject.authenticate
      FakeWeb.last_request.method.should eq "POST"
      FakeWeb.last_request.path.should eq "/sessions.xml"
    end
  end

  describe "#encode" do
    it "includes a user node with the email and password set" do
      subject.stub(:reload).and_return
      subject.authenticate
      body = { 'session' => { 'user' => { 'email' => user.email, 'password' => user.password } } }
      Hash.from_xml(FakeWeb.last_request.body).should eq body
    end
  end

  describe "#authenticated?" do
    context "with valid credentials" do
      it "is authenticated" do
        subject.authenticate
        subject.should be_authenticated
      end

      it "loads the membership_id into the associated user" do
        subject.authenticate
        subject.user.membership_id.should eq 1
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
