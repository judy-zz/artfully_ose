require 'spec_helper'

describe Discount do
  disconnect_sunspot
  subject { FactoryGirl.build(:discount) }
  let(:event) { subject.event }

  it "should be a valid discount" do
    subject.should be_valid
    subject.errors.should be_blank
  end

  specify "should not allow more than one of the same code in the same event" do
    @discount1 = FactoryGirl.build(:discount, code: "ALPHA", event: event)
    @discount2 = FactoryGirl.build(:discount, code: "ALPHA", event: event)
    @discount1.save.should be_true
    @discount2.save.should be_false
  end

  specify "should allow more than one of the same code in different events" do
    @event2 = FactoryGirl.build(:event)
    @discount1 = FactoryGirl.build(:discount, code: "ALPHA", event: event)
    @discount2 = FactoryGirl.build(:discount, code: "ALPHA", event: @event2)
    @discount1.save.should be_true
    @discount2.save.should be_true
  end

  specify "should not allow a code less than 4 characters" do
    FactoryGirl.build(:discount, code: "ABC").save.should be_false
  end

  specify "should not allow a code more than 15 characters" do
    FactoryGirl.build(:discount, code: "BETTERCALLKENNYLOGGINSBECAUSEYOUREINTHEDANGERZONE").save.should be_false
  end

  describe "before_destroy" do
    it "will be destroyed" do
      subject.save!
      Discount.all.should include(subject)
      subject.destroy.should be_true
      Discount.all.should_not include(subject)
    end
    context "when a ticket has been redeemed" do
      before { subject.stub(:redeemed) { 1 } }
      it("won't be destroyed") {subject.destroy.should be_false}
    end
  end

  describe "#destroyable?" do
    it "should return true when the ticket hasn't been used" do
      subject.destroyable?.should be_true
    end
    it "should return false when the ticket has been used" do
      subject.stub(:redeemed) { 1 }
      subject.destroyable?.should be_false
    end
  end
  
  describe "#set_organization_from_event" do
    it "should set the organization from the event's organization" do
      subject.organization = nil
      subject.set_organization_from_event
      subject.organization.should == event.organization
    end
  end

  describe "#shows" do
    before(:each) do
      @show = FactoryGirl.create(:show)
      subject.shows << @show
    end
    it "should return a list of shows that this discount is applicable to" do
      subject.shows.should include(@show)
    end
  end

  describe "#sections" do
    before(:each) do
      @section = FactoryGirl.create(:section)
      subject.sections << @section
    end
    it "should return a list of sections that this discount is applicable to" do
      subject.sections.should include(@section)
    end
  end

  describe "#eligible_tickets" do
    let(:cart)               {FactoryGirl.create(:cart)}
    let(:included_show_1)    {FactoryGirl.create(:show)}
    let(:included_show_2)    {FactoryGirl.create(:show)}
    let(:unincluded_show)    {FactoryGirl.create(:show)}
    let(:included_section_1) {FactoryGirl.create(:section)}
    let(:included_section_2) {FactoryGirl.create(:section)}
    let(:unincluded_section) {FactoryGirl.create(:section)}

    let(:ticket_1_1) {FactoryGirl.create(:ticket, show: included_show_1, section: included_section_1)}
    let(:ticket_2_1) {FactoryGirl.create(:ticket, show: included_show_2, section: included_section_1)}
    let(:ticket_u_1) {FactoryGirl.create(:ticket, show: unincluded_show, section: included_section_1)}
    let(:ticket_1_2) {FactoryGirl.create(:ticket, show: included_show_1, section: included_section_2)}
    let(:ticket_2_2) {FactoryGirl.create(:ticket, show: included_show_2, section: included_section_2)}
    let(:ticket_u_2) {FactoryGirl.create(:ticket, show: unincluded_show, section: included_section_2)}
    let(:ticket_1_u) {FactoryGirl.create(:ticket, show: included_show_1, section: unincluded_section)}
    let(:ticket_2_u) {FactoryGirl.create(:ticket, show: included_show_2, section: unincluded_section)}
    let(:ticket_u_u) {FactoryGirl.create(:ticket, show: unincluded_show, section: unincluded_section)}

    before(:each) do
      cart.tickets << [ticket_1_1, ticket_2_1, ticket_u_1, ticket_1_2, ticket_2_2, ticket_u_2, ticket_1_u, ticket_2_u, ticket_u_u]
      subject.cart = cart
    end

    [
      {:description => "no shows or sections",
        :shows => [],
        :sections => [],
        :tickets =>[ticket_1_1, ticket_2_1, ticket_u_1, ticket_1_2, ticket_2_2, ticket_u_2, ticket_1_u, ticket_2_u, ticket_u_u]},
      {:description => "one show",
        :shows => [included_show_1],
        :sections => [],
        :tickets =>[ticket_1_1, ticket_1_2, ticket_1_u]},
      {:description => "two shows",
        :shows => [included_show_1, included_show_2],
        :sections => [],
        :tickets =>[ticket_1_1, ticket_2_1, ticket_1_2, ticket_2_2, ticket_1_u, ticket_2_u]},
      {:description => "one section",
        :shows => [],
        :sections => [included_section_1],
        :tickets =>[ticket_1_1, ticket_2_1, ticket_u_1]},
      {:description => "two sections",
        :shows => [],
        :sections => [included_section_1, included_section_2],
        :tickets =>[ticket_1_1, ticket_2_1, ticket_u_1, ticket_1_2, ticket_2_2, ticket_u_2]},
      {:description => "one show and one section",
        :shows => [included_show_1],
        :sections => [included_section_1],
        :tickets =>[ticket_1_1, ticket_2_1, ticket_u_1, ticket_1_2, ticket_1_u]},
      {:description => "multiple shows and sections",
        :shows => [included_show_1, included_show_2],
        :sections => [included_section_1, included_section_2],
        :tickets =>[ticket_1_1, ticket_2_1, ticket_u_1, ticket_1_2, ticket_2_2, ticket_u_2, ticket_1_u, ticket_2_u]}
    ].each do |scenario|
      specify "#{scenario[:description]} should return the matching tickets" do
        subject.shows = scenario[:shows]
        subject.sections = scenario[:sections]
        subject.eligible_tickets =~ scenario[:tickets]
      end
    end
  end

  describe "#apply_discount_to_cart" do
    before(:each) do
      @cart = FactoryGirl.create(:cart_with_items)
      subject.event = @cart.tickets.first.event
      subject.cart = @cart
      subject.save!
    end
    context "with ten percent off" do
      before(:each) do
        subject.promotion_type = "PercentageOffTickets"
        subject.properties[:percentage] = 0.1
        subject.apply_discount_to_cart
      end
      it "should take ten percent off the cost of each ticket" do
        @cart.total.should == 15100 # 14500 + 600 in ticket fees that still apply
      end
      it "should set the discount on each ticket" do
        @cart.tickets.each{|t| t.discount.should == subject }
      end
    end
    context "with ten dollars off the order" do
      before(:each) do
        subject.promotion_type = "DollarsOffTickets"
        subject.properties[:amount] = 1000
        subject.apply_discount_to_cart
      end
      it "should take ten dollars off the cost of each ticket" do
        @cart.total.should == 13600
      end
      it "should set the discount on each ticket" do
        @cart.tickets.each{|t| t.discount.should == subject }
      end
    end
    context "with BOGOF" do
      before(:each) do
        # Add two more tickets
        @cart.tickets << 2.times.collect { FactoryGirl.create(:ticket) }
        subject.promotion_type = "BuyOneGetOneFree"
        subject.apply_discount_to_cart
      end
      it "should take the cost of every other ticket out of the total" do
        @cart.total.should == 17000
      end
      it "should set the discount on each ticket, except the last odd one" do
        id = subject.id
        @cart.tickets.collect{|t| t.discount_id}.should == [id, id, id, id, nil]
      end
    end
  end
end
