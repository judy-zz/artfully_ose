require 'spec_helper'

describe AthenaOrder do
  subject { Factory(:athena_order) }

  describe "schema" do
    it { should respond_to :person_id }
    it { should respond_to :organization_id }
    it { should respond_to :customer_id }
  end

  %w( person organization customer ).each do |association|
    it { should respond_to association }
    it { should respond_to association + "=" }
  end

  describe "organization" do
    it "should return the organization" do
      subject.organization.should be_an Organization
      subject.organization.id.should eq subject.organization_id
    end

    it "should store the organization id when the organization is set" do
      organization = Factory(:organization)
      subject.organization = organization
      subject.organization.should eq organization
    end
  end

  describe "person" do
    it "should fetch the People record" do
      person =  Factory(:athena_person_with_id)
      subject.person = person
      subject.person.should eq person
    end

    it "should not make a request if the customer_id is not set" do
      subject.person = subject.person_id = nil
      subject.person.should be_nil
    end

    it "should update the customer id when assigning a new customer record" do
      subject.person = Factory(:athena_person_with_id, :id => 2)
      subject.person_id.should eq(2)
    end
  end

  describe "customer" do
    it "should fetch the Customer record" do
      customer =  Factory(:customer_with_id)
      subject.customer = customer
      subject.customer.should eq customer
    end

    it "should not make a request if the customer_id is not set" do
      subject.customer = subject.customer_id = nil
      subject.customer.should be_nil
    end

    it "should update the customer id when assigning a new customer record" do
      subject.customer = Factory(:customer_with_id, :id => 2)
      subject.customer_id.should eq(2)
    end
  end
end
