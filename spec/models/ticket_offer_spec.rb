require 'spec_helper'

describe TicketOffer do

  subject { Factory(:ticket_offer) }

  it "should be valid" do
    subject.should be_valid
  end

  it "should validate the existence of its organization" do
    subject.organization = nil
    subject.should_not be_valid
  end

  it "should not raise an exception when offering a ticket in sequence" do
    subject.status = "creating"
    expect { subject.offer! }.should_not raise_error
  end

  it "should raise an exception when offering a ticket out of sequence" do
    subject.status = "completed"
    expect { subject.offer! }.should raise_error
  end

  it "should have a reseller organization" do
    subject.reseller_organization.should == subject.reseller_profile.organization
  end

  it "should know that a ticket matches the offer" do
    ticket = Factory :ticket, organization: subject.organization, show: subject.show, section: subject.section
    subject.should be_valid_ticket ticket
  end

  it "should know that a ticket does not match the offer" do
    ticket = Factory :ticket
    subject.should_not be_valid_ticket ticket
  end

  context "a ticket offer of 7 tickets to a show with 20 tickets" do

    before do
      FakeWeb.register_uri :post, "http://localhost:8982/solr/update?wt=ruby", body: ""
      @producer = Factory :organization
      @event = Factory :event, organization: @producer
      @chart = Factory :chart, event: @event, organization: @producer
      @show = Factory :show, organization: @producer, event: @event, chart: @chart
      @section = Factory :section, capacity: 20, chart: @chart
      @tickets = (1..20).map { Factory :ticket, state: "on_sale", show: @show, organization: @producer, section: @section }
      @ticket_offer = Factory :ticket_offer, organization: @producer, show: @show, section: @section, count: 7
      @reseller = @ticket_offer.reseller_organization
    end

    subject { @ticket_offer }

    context "with none sold" do
      it("should have 7 available") { subject.available.should == 7 }
      it("should have 0 sold") { subject.sold.should == 0 }
    end

    context "with 1 sold" do
      before do
        sell_tickets subject, 1
      end
      it("should have 6 available") { subject.available.should == 6 }
      it("should have 1 sold") { subject.sold.should == 1 }
    end

    context "with 2 sold on a single order" do
      before do
        sell_tickets subject, 2
      end
      it("should have 5 available") { subject.available.should == 5 }
      it("should have 2 sold") { subject.sold.should == 2 }
    end

    context "with 6 sold on 3 orders" do
      before do
        sell_tickets subject, 1
        sell_tickets subject, 2
        sell_tickets subject, 3
      end
      it("should have 1 available") { subject.available.should == 1 }
      it("should have 6 sold") { subject.sold.should == 6 }
    end

    context "with 7 sold on a single order" do
      before do
        sell_tickets subject, 7
      end
      it("should have 0 available") { subject.available.should == 0 }
      it("should have 7 sold") { subject.sold.should == 7 }
    end

    def sell_tickets ticket_offer, count
      person = Factory :person
      order = Factory :reseller_order, organization: subject.reseller_organization, person: person
      show = ticket_offer.show
      event = show.event
      section = ticket_offer.section

      @tickets[0, count].each do |ticket|
        order.items << Factory(:item, product: ticket, order: nil, reseller_order: order, show: show)
      end

      order.save!
    end

  end

end
