require 'spec_helper'

describe Job::ResellerSettlement do
  let(:last_month) { ResellerSettlement.range_for_previous_month DateTime.now }

  disconnect_sunspot
  describe ".run" do
    let(:organization) { Factory(:organization_with_reselling, :bank_account => Factory(:bank_account)) }
    let(:settlement) { Factory(:reseller_settlement) }

    it "should call the methods using a date range" do
      range = (DateTime.now.beginning_of_month.to_date .. DateTime.now.end_of_month.to_date)
      Job::ResellerSettlement.should_receive(:settle_shows_in).with(ResellerSettlement.range_for(DateTime.now))
      Job::ResellerSettlement.run
    end

    it "should settle a show on the edge of the date range" do
      range = ResellerSettlement.range_for_previous_month(DateTime.now)
      show = Factory(:show, :organization => organization, :event => Factory(:event))
      show.datetime = range[0]
      show.save(:validate => false)

      create_order_for_show(show)

      ResellerSettlement.should_receive(:submit).with(organization.id, [@item], organization.bank_account).and_return(settlement)
      Job::ResellerSettlement.run
    end

    it "should not settle a show outside of the date range" do
      settlement.stub(:submit).and_return(nil)
      range = ResellerSettlement.range_for(DateTime.now)
      show = Factory(:show, :organization => organization, :event => Factory(:event))
      show.datetime = range[0] - 1.minute
      show.save(:validate => false)

      create_order_for_show(show)

      Job::ResellerSettlement.should_receive(:settle_shows_in)
      ResellerSettlement.should_not_receive(:submit)
      Job::ResellerSettlement.run
    end
  end

  describe ".settle_shows_in" do
    let(:organization) { Factory(:organization_with_reselling, :bank_account => Factory(:bank_account)) }
    let(:shows) { 3.times.collect{ Factory(:show, :organization => organization, :event => Factory(:event)) } }
    let(:settlement) { Factory (:reseller_settlement) }

    before(:each) do
      settlement.stub(:submit).and_return(nil)
      shows.each { |show| show.stub(:reseller_settleables).and_return(5.times.collect{ Factory(:item) } ) }
      Show.stub(:in_range).and_return(shows)
    end

    it "should not settle a show if it is part of a deleted event" do
      items = []
      shows.first.event.destroy
      shows.reject(&:event_deleted?).each do |show|
        items << create_order_for_show(show)
      end
      ResellerSettlement.should_receive(:submit).with(organization.id, items, organization.bank_account).and_return(settlement)
      Job::ResellerSettlement.settle_shows_in(ResellerSettlement.range_for DateTime.now.next_month)
    end

    it "creates and submit a ResellerSettlement for each show", :testing => true do
      items = []
      shows.each do |show|
        items << create_order_for_show(show)
      end
      ResellerSettlement.should_receive(:submit).with(organization.id, items, organization.bank_account).and_return(settlement)
      Job::ResellerSettlement.settle_shows_in(ResellerSettlement.range_for(DateTime.now.next_month))
    end
  end

  describe "when disaster strikes" do
    let(:organizations) { 2.times.collect {Factory(:organization, :bank_account => Factory(:bank_account)) } }

    it "should recover and continue settling if there is a problem" do
      Organization.any_instance.stub(:items_sold_as_reseller_during).and_return(Array.wrap(Factory(:item)))
      ResellerSettlement.should_receive(:submit).exactly(Organization.all.size).times.and_raise(Exception.new)
      Job::ResellerSettlement.settle_shows_in(ResellerSettlement.range_for(DateTime.now.next_month))
    end
  end

  def create_order_for_show(show)
    @order = Factory(:reseller_order, :organization => show.organization)
    @ticket = Factory(:ticket, :organization => show.organization, :show => show)
    @item = Factory(:item, :product => @ticket)
    @order.items << @item
    @order.save!

    return @item
  end
end
