require 'spec_helper'

describe Person do
  disconnect_sunspot
  subject { Factory(:person) }

  describe "#valid?" do
    before(:each) do
      FakeWeb.register_uri(:get, %r|http://localhost/athena/people\.json\?email=.*&organizationId=.*|, :body => "[]")
    end

    it { should be_valid }
    it { should respond_to :email }

    it "should be valid with one of the following: first name, last name, email" do
      subject.email = 'something@somewhere.com'
      subject.first_name = nil
      subject.last_name = nil
      subject.should be_valid

      subject.email = nil
      subject.first_name = 'First!'
      subject.last_name = nil
      subject.should be_valid

      subject.email = nil
      subject.first_name = nil
      subject.last_name = 'Band'
      subject.should be_valid

      subject.email = nil
      subject.first_name = ''
      subject.last_name = 'Band'
      subject.should be_valid
    end

    it "should not be valid without a first name, last name or email address" do
      subject.first_name = nil
      subject.last_name = nil
      subject.email = nil
      subject.should_not be_valid
    end
  end

  describe "#find_by_customer" do
    let(:organization) { Factory(:organization) }
    it "should find by person_id if one is present" do
      customer = AthenaCustomer.new({
        :person_id => subject.id,
        :email => "person@example.com",
        :organization_id => organization.id
      })
      Person.should_receive(:find).with(customer.person_id)
      p = Person.find_by_customer(customer, organization)
    end
    
    it "should find by email and org if no person_id is present" do
      customer = AthenaCustomer.new({
        :email => "person@example.com",
        :organization_id => organization.id
      })
      params = {
        :email => "person@example.com",
        :organization_id => organization.id
      }
      Person.should_not_receive(:find).with(customer.person_id)
      Person.should_receive(:find).with(:first, :conditions => params)
      p = Person.find_by_customer(customer, organization)
    end
    
    it "should return nil if no person_id or email is provided" do
      customer = AthenaCustomer.new({
        :organization_id => organization.id
      })
      params = {
        :organization_id => organization.id
      }
      Person.should_not_receive(:find).with(customer.person_id)
      Person.should_not_receive(:find).with(:first, :conditions => params)
      p = Person.find_by_customer(customer, organization)
      p.should be_nil
    end
  end

  describe "#find_by_email_and_organization" do
    let(:organization) { Factory(:organization) }

    before(:each) do
      Person.stub(:find).and_return
    end

    it "should search for the Person by email address and organization" do
      params = {
        :email => "person@example.com",
        :organization_id => organization.id
      }
      Person.should_receive(:find).with(:first, :conditions => params)
      Person.find_by_email_and_organization("person@example.com", organization)
    end

    it "should return nil if it doesn't find anyone" do
      email = "person@example.com"
      p = Person.find_by_email_and_organization(email, organization)
      p.should eq nil
    end
  end

  describe "organization" do
    it { should respond_to :organization }
    it { should respond_to :organization_id }
  end

  describe "uniqueness" do
    subject { Factory.build(:person) }
    it "should not be valid if another person record exists with that email for the organization" do
      Factory(:person, :email => subject.email, :organization => subject.organization)
      subject.should_not be_valid
    end
  end

  describe "#dummy_for" do
    let(:organization) { Factory(:organization) }
    it "fetches the dummy record for the organization" do
      person = Person.dummy_for(organization)
      Person.dummy_for(organization).should eq person
    end

    it "creates the dummy record if one does not yet exist" do
      person = Person.dummy_for(organization)
      person.dummy.should be_true
    end
  end

end
