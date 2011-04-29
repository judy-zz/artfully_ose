require 'spec_helper'

describe FA::User do
  subject { Factory(:fa_user) }

  it { should be_valid }

  describe "#valid?" do
    it "is not valid without a password" do
      subject.password = nil
      subject.should_not be_valid
    end

    context "without a username" do
      before(:each) do
        subject.username = ""
      end

      it "is not valid without an email" do
        subject.email = nil
        subject.should_not be_valid
      end

      it "is valid with an email" do
        subject.email = "something"
        subject.should be_valid
      end
    end

    context "without an email" do
      before(:each) do
        subject.email = ""
      end

      it "is not valid without a username" do
        subject.username = nil
        subject.should_not be_valid
      end

      it "is valid with a username" do
        subject.username = "user"
        subject.should be_valid
      end
    end
  end

  describe "#to_xml" do
    it "does not include the username if the email is present" do
      subject.encode.should_not match /username/
    end

    it "does include the username if the email is blank" do
      subject.email = ""
      subject.encode.should match /username/
    end

    it "does not include the email if it is blank" do
      subject.email = ""
      subject.encode.should_not match /email/
    end
  end

  describe "password" do
    it "hashes the password when loading it" do
      subject.stub(:save)
      subject.update_attributes({:password => "something"})
      subject.password.should eq Digest::MD5.hexdigest("something")
    end

    it "hashes the password when assigned directly" do
      subject.password = "something"
      subject.password.should eq Digest::MD5.hexdigest("something")
    end
  end

  describe "#authenticate" do
    before(:each) do
      id = 1
      body = { :session => { :user => { :membership_id => 1 } } }.to_xml
      FakeWeb.register_uri(:get, "http://api.fracturedatlas.org/sessions/#{id}.xml", :body => body)
      FakeWeb.register_uri(:post, "http://api.fracturedatlas.org/sessions.xml", :location => "http://api.fracturedatlas.org/sessions/#{id}.xml")
    end

    it "returns false if the user is invalid" do
      subject.stub(:valid?).and_return(false)
      subject.authenticate.should be_false
    end

    context "with valid credentials" do
      specify { subject.authenticate.should be_true }
    end

    context "with invalid credentials" do
      before(:each) do
        FakeWeb.register_uri(:post, "http://api.fracturedatlas.org/sessions.xml", :status => 403)
      end
      specify { subject.authenticate.should be_false }
    end
  end
end
