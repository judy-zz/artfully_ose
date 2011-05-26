require 'spec_helper'

describe AthenaGlanceReport do
  before(:each) do
    body = '{"performancesOnSale":40,"revenue":{"advanceSales":{"gross":300.0,"net":270.0},"soldToday":{"gross":90.0,"net":81.0},"potentialRemaining":{"gross":2885.74,"net":2558.33},"originalPotential":{"gross":29635.55,"net":19885.02},"totalSales":{"gross":9959.99,"net":4562.25},"totalPlayed":{"gross":4500.44,"net":4000.8}},"tickets":{"sold":{"gross":100,"comped":20},"soldToday":{"gross":10,"comped":0},"played":{"gross":9},"available":65}}'
    FakeWeb.register_uri(:get, "http://localhost/reports/glance/.json?eventId=1", :body => body)
  end

  subject { AthenaGlanceReport.find(nil, :params => { :eventId => 1 } ) }

  it { should respond_to :performances_on_sale }
  it { should respond_to :revenue }
  it { should respond_to :tickets }

  describe "#performances_on_sale" do
    it "stores the value from the report" do
      subject.performances_on_sale.should eq 40
    end
  end

  describe "Revenue" do
    subject { AthenaGlanceReport.find(nil, :params => { :eventId => 1 } ).revenue }
    [ :advance_sales, :sold_today, :potential_remaining, :original_potential, :total_sales, :total_played ].each do |attr|
      it { should respond_to(attr) }
    end
  end

  describe "Tickets" do
    subject { AthenaGlanceReport.find(nil, :params => { :eventId => 1 } ).tickets }
    [ :sold, :sold_today, :played, :available ].each do |attr|
      it { should respond_to(attr) }
    end
  end
end
