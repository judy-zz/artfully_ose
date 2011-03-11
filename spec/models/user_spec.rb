require 'spec_helper'

describe User do
  subject { Factory(:user) }

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
      subject.should_not be_active
    end

    it "should be active when it is unsuspended" do
      subject.unsuspend!
      subject.should be_active
    end

    it "should not remain suspended after unsuspension" do
      subject.suspend!
      subject.should be_suspended
      subject.unsuspend!
      subject.should_not be_suspended
    end
  end

  describe ".customer" do
    it { should respond_to(:customer_id) }
    it { should respond_to(:customer) }

    it "should fetch the remote customer record" do
      @customer = Factory(:customer, :id => 1)
      subject.customer_id = @customer.id
      FakeWeb.register_uri(:get, "http://localhost/payments/customers/#{@customer.id}.json", :body => @customer.encode)
      subject.customer.should eq(@customer)
    end

    it "should not make a request if the customer_id is not set" do
      subject.customer_id = nil
      subject.customer.should be_nil
    end

    it "should update the customer id when assigning a new customer record" do
      subject.customer = Factory(:customer, :id => 2)
      subject.customer_id.should eq(2)
    end

    it "should set the customer id to nil if the remote resource no longer has it" do
      subject.customer_id = 1
      FakeWeb.register_uri(:get, "http://localhost/payments/customers/1.json", :status => 404)
      subject.customer.should be_nil
    end
  end

  describe ".credit_cards" do
    it { should respond_to :credit_cards }
    it { should respond_to :credit_cards= }

    it "should return an empty array if customer is not set" do
      subject.customer = nil
      subject.credit_cards.should be_empty
    end

    it "should return any credit cards associated with the customer record" do
      customer = Factory(:customer_with_credit_cards)
      subject.customer = customer
      subject.credit_cards.should eq customer.credit_cards
    end

    it "should delegate credit card assignemnt to the customer" do
      subject.customer = Factory(:customer_with_id)
      credit_card = Factory(:credit_card)
      subject.credit_cards << credit_card
      subject.credit_cards.should eq subject.customer.credit_cards
    end
  end

  describe "roles" do
    it { should respond_to(:roles) }
    it { should respond_to(:has_role?) }

    describe "#has_role?" do
      it "admin should return true when the user is a admin" do
        subject = Factory(:admin)
        subject.should have_role :admin
      end

      it "producer should return true when the user is a producer" do
        subject = Factory(:producer)
        subject.should have_role :producer
      end

      it "patron should return true when the user is a patron" do
        subject = Factory(:patron)
        subject.should have_role :patron
      end
    end

    describe ".add_role" do
      it "should add the role if the user does not already have it" do
        subject.add_role(:producer)
        subject.should have_role(:producer)
      end

      it "should not add the role if the user already has it" do
        2.times { subject.add_role :producer }
        subject.roles.length.should eq 1
      end
    end

    it "#to_producer" do
      subject.to_producer
      subject.save
      subject.roles.should include(Role.producer)
    end
  end

  describe "organizations" do
    let(:organization) { Factory(:organization) }

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
