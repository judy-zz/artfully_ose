require 'spec_helper'

describe AthenaTicket do

  describe "attributes" do
    subject { Factory(:ticket) }

    it { should respond_to :event }
    it { should respond_to :event_id }
    it { should respond_to :venue }
    it { should respond_to :performance }
    it { should respond_to :performance_id }
    it { should respond_to :price }
    it { should respond_to :buyer_id }
    it { should respond_to :sold_at }
    it { should respond_to :sold_price }
  end

  describe "#find" do
    it "fetch a ticket by ID" do
      @fake_ticket = Factory(:ticket_with_id)
      @ticket = AthenaTicket.find(@fake_ticket.id)
      @ticket.should_not be_nil
      @ticket.should eq @fake_ticket
      @ticket.should be_valid
    end

    it "should raise ForbiddenAccess when attempting to fetch all tickets" do
      FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json", :status => "403")
      lambda { AthenaTicket.all }.should raise_error(ActiveResource::ForbiddenAccess)
    end

    it "should raise ResourceNotFound for invalid IDs" do
      FakeWeb.register_uri(:get, "http://localhost/athena/tickets/0.json", :status => ["404", "Not Found"])
      lambda { AthenaTicket.find(0) }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should generate a query string for a single parameter search" do
      @ticket = Factory(:ticket, :price => 50)
      FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?price=eq50", :body => "[#{@ticket.encode}]" )
      @tickets = AthenaTicket.find(:all, :params => {:price => "eq50"})
      @tickets.map { |ticket| ticket.price.should == 50 }
    end
  end

  describe ".destroy" do
    subject { Factory(:ticket_with_id) }

    it "should issue a DELETE when destroying a ticket" do
      FakeWeb.register_uri(:delete, "http://localhost/athena/tickets/#{subject.id}.json", :status => "204")
      subject.destroy

      FakeWeb.last_request.method.should == "DELETE"
      FakeWeb.last_request.path.should == "/athena/tickets/#{subject.id}.json"
    end

    it "should not delete a ticket that has been marked as sold" do
      subject.state = "sold"
      subject.destroy
      FakeWeb.last_request.should be_nil
    end
  end

  describe ".save" do
    it "should issue a PUT when updating a ticket" do
      @ticket = Factory(:ticket_with_id)
      FakeWeb.register_uri(:put, "http://localhost/athena/tickets/#{@ticket.id}.json", :body => @ticket.encode)
      @ticket.save

      FakeWeb.last_request.method.should == "PUT"
      FakeWeb.last_request.path.should == "/athena/tickets/#{@ticket.id}.json"
    end

    it "should issue a POST when creating a new AthenaTicket" do
      FakeWeb.register_uri(:post, "http://localhost/athena/tickets.json", :body => "{}")
      @ticket = Factory.create(:ticket)

      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == "/athena/tickets.json"
    end
  end

  describe "available tickets" do
    it "by performance" do
      FakeWeb.register_uri(:get, %r|http://localhost/athena/tickets/available\.json\?.*|, :body => "[]")
      now = DateTime.now
      params = { "performance" => "eq#{now.as_json}" }
      AthenaTicket.available(params)
      FakeWeb.last_request.path.should match %r|performance=eq#{CGI::escape now.as_json}|

    end

    it "should add _limit to the query string when included in the arguments" do
      FakeWeb.register_uri(:get, %r|http://localhost/athena/tickets/available\.json\?_limit=4.*|, :body => "[]")
      params = { "limit" => "4" }
      AthenaTicket.available(params)
      FakeWeb.last_request.path.should match "_limit=4"
    end

    it "should default to searching for tickets marked as on sale" do
      FakeWeb.register_uri(:get, %r|http://localhost/athena/tickets/available\.json\?.*|, :body => "[]")
      AthenaTicket.available({})
      FakeWeb.last_request.path.should match "state=on_sale"
    end

    it "should raise an error if an unknown attribute is used" do
      lambda { AthenaTicket.available({:foo => "bar"}) }.should raise_error(ArgumentError)
    end

    it "should camelize the keys for the search terms" do
      FakeWeb.register_uri(:get, %r|http://localhost/athena/tickets/available\.json\?.*|, :body => "[]")
      AthenaTicket.available({:performance_id => 1})
      FakeWeb.last_request.path.should match "performanceId"
    end
  end

  describe "#expired?" do
    it "should be expired if the performance time is in the past" do
      subject.performance = DateTime.now - 1.day
      subject.should be_expired
    end

    it "should not be expired if the performance time is in the future" do
      subject.performance = DateTime.now + 1.day
      subject.should_not be_expired
    end
  end

  describe ".on_sale?" do
    subject { Factory(:ticket_with_id, :state => "on_sale") }
    it { should be_on_sale }
    it { should_not be_off_sale }
  end

  describe ".on_sale!" do
    subject { Factory(:ticket_with_id) }

    it { should respond_to :on_sale! }

    it "should mark the ticket as on sale" do
      subject.stub(:save!)
      subject.on_sale!
      subject.should be_on_sale
    end

    it "should save the updated ticket" do
      subject.stub!(:save!)
      subject.should_receive(:save!)
      subject.on_sale!
    end
  end

  describe ".off_sale?" do
    subject { Factory(:ticket_with_id, :on_sale => false) }
    it { should be_off_sale }
    it { should_not be_on_sale }
  end

  describe ".off_sale!" do
    subject { Factory(:ticket_with_id, :state => "on_sale") }

    it { should respond_to :off_sale! }

    it "should mark the ticket as on sale" do
      subject.stub(:save!)
      subject.off_sale!
      subject.should_not be_on_sale
    end

    it "should save the updated ticket" do
      subject.stub!(:save!)
      subject.should_receive(:save!)
      subject.off_sale!
    end
  end

  describe "take_off_sale" do
    it "should not be marked as off sale if it is already sold" do
      subject.state = "sold"
      subject.should_not_receive(:save!)
      subject.take_off_sale
      subject.should be_sold
    end

    it "should return false if it is already sold" do
      subject.state = "sold"
      subject.stub(:save!)
      subject.take_off_sale.should be_false
    end
  end

  describe ".sell_to" do
    let (:buyer) { Factory(:athena_person_with_id) }
    subject { Factory(:ticket_with_id, :state=>"on_sale") }

    it "should default to current time if time is not provided" do
      subject.stub!(:save!)
      subject.sell_to(buyer)
      subject.sold_at.should_not eq nil
    end

    it "should set sold_at to the time provided" do
      subject.stub!(:save!)
      when_it_got_sold = Time.now
      sleep 1
      subject.sell_to(buyer, when_it_got_sold)
      subject.sold_at.should eq when_it_got_sold
    end

    it "should set sold_price to price" do
      subject.stub!(:save!)
      subject.sell_to(buyer)
      subject.sold_price.should eq subject.price
    end

    it "should mark the ticket as sold" do
      subject.stub!(:save!)
      subject.sell_to(buyer)
      subject.state.should == "sold"
    end

    it "should save the updated ticket" do
      subject.stub!(:save!)
      subject.should_receive(:save!)
      subject.sell_to(buyer)
    end

    it "should set the buyer after being sold" do
      subject.stub!(:save!)
      subject.sell_to(buyer)
      subject.buyer.should eq buyer
    end
  end

   describe ".comp_to" do
    let (:buyer) { Factory(:athena_person_with_id) }
    subject { Factory(:ticket_with_id, :state=>"on_sale") }

    it "should mark the ticket as comped" do
      subject.stub!(:save!)
      subject.comp_to(buyer)
      subject.state.should == "comped"
    end

    it "should default to current time if time is not provided" do
      subject.stub!(:save!)
      subject.comp_to(buyer)
      subject.sold_at.should_not eq nil
    end

    it "should set the sold_price to 0" do
      subject.stub!(:save!)
      subject.comp_to(buyer)
      subject.sold_price.should eq 0
    end

    it "should set sold_at to the time provided" do
      subject.stub!(:save!)
      when_it_got_sold = Time.now
      sleep 1
      subject.comp_to(buyer, when_it_got_sold)
      subject.sold_at.should eq when_it_got_sold
    end

    it "should save the updated ticket" do
      subject.stub!(:save!)
      subject.should_receive(:save!)
      subject.comp_to(buyer)
    end

    it "should set the buyer after being sold" do
      subject.stub!(:save!)
      subject.comp_to(buyer)
      subject.buyer.should eq buyer
    end
  end

  describe "buyer" do
    it { should respond_to :buyer }
    it { should respond_to :buyer= }

    it "should fetch the People record" do
      person =  Factory(:athena_person_with_id)
      subject.buyer = person
      subject.buyer.should eq person
    end

    it "should not make a request if the customer_id is not set" do
      subject.buyer_id = nil
      subject.buyer.should be_nil
    end

    it "should update the customer id when assigning a new customer record" do
      subject.buyer = Factory(:athena_person_with_id, :id => 2)
      subject.buyer_id.should eq(2)
    end
  end

  describe "#returnable?" do
    it "is returnable if it is not expired" do
      subject.stub(:expired?).and_return(false)
      subject.should be_returnable
    end

    it "is not returnable if it is expired" do
      subject.stub(:expired?).and_return(true)
      subject.should_not be_returnable
    end
  end

  describe "#exchangeable?" do
    it "is exchangeable if it is not expired and sold" do
      subject.stub(:expired?).and_return(false)
      subject.stub(:sold?).and_return(true)
      subject.should be_exchangeable
    end

    it "is not exchangeable if it is expired" do
      subject.stub(:expired?).and_return(true)
      subject.should_not be_exchangeable
    end

    it "is not exchangeable if it is expired" do
      subject.stub(:comped?).and_return(true)
      subject.should_not be_exchangeable
    end
  end

  describe "#refundable?" do
    it "is refundable if it is sold" do
      subject.stub(:sold?).and_return(true)
      subject.should be_refundable
    end

    it "is not refundable if it is comped" do
      subject.stub(:comped?).and_return(true)
      subject.should_not be_refundable
    end
  end

  describe "return!" do
    subject { Factory(:ticket_with_id, :performance => DateTime.now + 1.day, :buyer => Factory(:athena_person_with_id), :state => :sold) }
    it "removes the buyer from the item" do
      subject.stub(:save!)
      subject.return!
      subject.buyer_id.should be_nil
    end

    it "should kill the sold price and sold time" do
      subject.stub(:save!)
      subject.return!
      subject.sold_at.should be_nil
      subject.sold_price.should eq 0
      subject.state.should eq("on_sale")
    end

    it "should put the ticket back on sale" do
      subject.stub(:save!)
      subject.return!
      subject.state.should eq("on_sale")
    end
  end

  describe ".put_on_sale" do
    let(:tickets) { 5.times.collect { Factory(:ticket_with_id, :state => :off_sale) } }

    before(:each) do
      body = tickets.collect(&:encode).join(",").gsub(/off_sale/,'on_sale')
      FakeWeb.register_uri(:put, "http://localhost/athena/tickets/patch/#{tickets.collect(&:id).join(',')}", :body => "[#{body}]")
    end

    it "sends a request to patch the state of all tickets" do
      AthenaTicket.put_on_sale(tickets)
      FakeWeb.last_request.method.should == "PUT"
      FakeWeb.last_request.body.should match /"state":"on_sale"/
    end

    it "does not issue the request if any of the tickets can not be put on sale" do
      tickets.first.state = :on_sale
      AthenaTicket.should_not_receive(:patch)
      AthenaTicket.put_on_sale(tickets)
    end

    it "updates the attributes for each ticket" do
      AthenaTicket.put_on_sale(tickets)
      tickets.each do |ticket|
        ticket.should be_on_sale
      end
    end
  end

  describe ".take_off_sale" do
    let(:tickets) { 5.times.collect { Factory(:ticket_with_id, :state => :on_sale) } }

    before(:each) do
      body = tickets.collect(&:encode).join(",").gsub(/on_sale/,'off_sale')
      FakeWeb.register_uri(:put, "http://localhost/athena/tickets/patch/#{tickets.collect(&:id).join(',')}", :body => "[#{body}]")
    end

    it "sends a request to patch the state of all tickets" do
      AthenaTicket.take_off_sale(tickets)
      FakeWeb.last_request.method.should == "PUT"
      FakeWeb.last_request.body.should match /"state":"off_sale"/
    end

    it "does not issue the request if any of the tickets can not be put on sale" do
      tickets.first.state = :off_sale
      AthenaTicket.should_not_receive(:patch)
      AthenaTicket.take_off_sale(tickets)
    end

    it "updates the attributes for each ticket" do
      AthenaTicket.take_off_sale(tickets)
      tickets.each do |ticket|
        ticket.should be_off_sale
      end
    end
  end
end