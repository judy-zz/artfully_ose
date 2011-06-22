require 'spec_helper'

describe Settlement do
  let(:items) do
    10.times.collect { |id| mock(:item, {:price => 1200, :realized_price => 1000, :net => 965, :id => id }) }
  end

  let(:bank_account) { Factory(:bank_account) }
  let(:organization) { Factory(:organization_with_id) }
  subject { Settlement.new }

  it "should set the created_at time when initialized" do
    subject.created_at.should_not be_nil
  end

  describe ".submit" do
    before(:each) do
      AthenaItem.stub(:settle).and_return(items)
      FakeWeb.register_uri(:post, "http://localhost/orders/settlements.json", :body => "")
      ACH::Request.stub(:for).and_return(mock(:request, :submit => "1231234"))
    end

    it "sums the net from the items" do
      ACH::Request.should_receive(:for).with(9650, bank_account, "Artful.ly Settlement #{Date.today}").and_return(mock(:request, :submit => "011231234"))
      Settlement.submit(organization.id, items, bank_account)
    end

    it "submits the request to the ACH API" do
      Settlement.should_receive(:send_request).with(items, bank_account, "Artful.ly Settlement #{Date.today}")
      Settlement.submit(organization.id, items, bank_account)
    end

    it "returns a settlement instance with the transaction_id set from the ACH request" do
      settlement = Settlement.submit(items, bank_account)
      settlement.transaction_id.should eq "1231234"
    end

    it "updates the items with the new settlement ID" do
      AthenaItem.should_receive(:settle)
      Settlement.submit(organization.id, items, bank_account)
    end

    it "does not send a request if there are no items to settle" do
      Settlement.should_not_receive(:send_request)
      Settlement.submit(organization.id, [], bank_account)
      Settlement.submit(organization.id, nil, bank_account)
    end

    it "does not mark the items if the ACH request fails" do
      Settlement.stub(:send_request).and_raise(ACH::ClientError.new("02"))
      Settlement.should_not_receive(:for_items)
      Settlement.submit(organization.id, items, bank_account)
    end
  end

  describe "#range_for" do
    let(:jobs) do
      {
        :monday     => Time.now.beginning_of_week          + 2.hours, # Monday 2AM
        :tuesday    => Time.now.beginning_of_week + 1.day  + 2.hours, # Tuesday 2AM
        :wednesday  => Time.now.beginning_of_week + 2.days + 2.hours, # Wednesday 2AM
        :thursday   => Time.now.beginning_of_week + 3.days + 2.hours, # Thursday 2AM
        :friday     => Time.now.beginning_of_week + 4.days + 2.hours  # Friday 2AM
      }
    end

    it "determines 48 business hours before the beginning of the day; " do
      target = jobs[:thursday].beginning_of_day - 1.week
      Settlement.range_for(jobs[:tuesday]).should eq [ target, target.end_of_day ]

      target = jobs[:wednesday].beginning_of_day - 1.week
      Settlement.range_for(jobs[:monday]).should eq [ target, target.end_of_day ]

      target = jobs[:tuesday].beginning_of_day
      Settlement.range_for(jobs[:friday]).should eq [ target, target.end_of_day ]

      target = jobs[:monday].beginning_of_day
      Settlement.range_for(jobs[:thursday]).should eq [ target, target.end_of_day ]
    end

    it "includes weekend dates if they occur during settlement period" do
      friday = jobs[:friday].beginning_of_day - 1.week
      sunday = friday + 2.days
      Settlement.range_for(jobs[:wednesday]).should eq [ friday, sunday.end_of_day ]
    end
  end

  describe "#items" do
    it "should fetch items from ATHENA" do
      FakeWeb.register_uri(:get, "http://localhost/orders/items.json?settlementId=1", :body => "")
      subject.items
    end
  end

  describe ".for_items" do
    subject { Settlement.for_items(items)}
    it "creates a new settlement instance with the gross calculated from the items" do
      subject.gross.should eq items.sum(&:price)
    end

    it "creates a new settlement instance with the realized gross calculated from the items" do
      subject.realized_gross.should eq items.sum(&:realized_price)
    end

    it "creates a new settlement instance with the net calculated from the items" do
      subject.net.should eq items.sum(&:net)
    end

    it "creates a new settlement instance with the items count set to the total number of settled items" do
      subject.items_count.should eq items.size
    end
  end
end
