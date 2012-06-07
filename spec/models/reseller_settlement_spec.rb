require 'spec_helper'

describe ResellerSettlement do
  disconnect_sunspot
  let(:items) { 10.times.collect { Factory(:item) } }
  let(:total) { items.sum(&:reseller_net) }

  let(:bank_account) { Factory(:bank_account) }
  let(:organization) { Factory(:organization) }
  let(:show)  { Factory(:show) }
  subject { ResellerSettlement.new }

  describe ".submit" do
    before(:each) do
      ACH::Request.stub(:for).and_return(mock(:request, :submit => "1231234"))
      Item.stub(:settle).and_return(items)
      show.id = 1
    end

    it "should handle any exception when trying to communicate with FirstACH" do
      ACH::Request.stub(:for).and_raise(Errno::ECONNRESET)
      settlement = ResellerSettlement.submit(organization.id, items, bank_account, show.id)
      settlement.success?.should be_false
    end

    it "sums the net from the items" do
      ACH::Request.should_receive(:for).with(total, bank_account, "Artful.ly Settlement #{Date.today}").and_return(mock(:request, :submit => "011231234"))
      ResellerSettlement.submit(organization.id, items, bank_account, show.id)
    end

    it "submits the request to the ACH API" do
      ResellerSettlement.should_receive(:send_request).with(items, bank_account, "Artful.ly Settlement #{Date.today}")
      ResellerSettlement.submit(organization.id, items, bank_account, show.id)
    end

    it "returns a settlement instance with the transaction_id set from the ACH request" do
      settlement = ResellerSettlement.submit(organization.id, items, bank_account, show.id)
      settlement.transaction_id.should eq "1231234"
      settlement.ach_response_code.should eq ACH::Request::SUCCESS
      settlement.success?.should be_true
    end

    it "updates the items with the new settlement ID" do
      Item.should_receive(:settle)
      ResellerSettlement.submit(organization.id, items, bank_account)
    end

    it "does not send a request if there are no items to settle but considers the settlement a success" do
      ResellerSettlement.should_not_receive(:send_request)
      settlement = ResellerSettlement.submit(organization.id, [], bank_account, show.id)
      settlement.success?.should be_true
      settlement = ResellerSettlement.submit(organization.id, nil, bank_account, show.id)
      settlement.success?.should be_true
    end

    it "does not mark the items if the ACH request fails" do
      ResellerSettlement.stub(:send_request).and_raise(ACH::ClientError.new("02"))
      Item.should_not_receive(:settle)
      settlement = ResellerSettlement.submit(organization.id, items, bank_account, show.id)
      settlement.ach_response_code.should eq "02"
      settlement.success?.should be_false
    end
  end

  describe ".for_items" do
    subject { ResellerSettlement.for_items(items)}
    it "creates a new settlement instance with the gross calculated from the items" do
      subject.gross.should eq items.sum(&:price)
    end

    it "creates a new settlement instance with the realized gross calculated from the items" do
      subject.realized_gross.should eq items.sum(&:realized_price)
    end

    it "creates a new settlement instance with the net calculated from the items" do
      subject.net.should eq items.sum(&:reseller_net)
    end

    it "creates a new settlement instance with the items count set to the total number of settled items" do
      subject.items_count.should eq items.size
    end
  end
end
