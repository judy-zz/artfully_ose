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
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json", :status => "403")
      lambda { AthenaTicket.all }.should raise_error(ActiveResource::ForbiddenAccess)
    end

    it "should raise ResourceNotFound for invalid IDs" do
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets/0.json", :status => ["404", "Not Found"])
      lambda { AthenaTicket.find(0) }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should generate a query string for a single parameter search" do
      @ticket = Factory(:ticket, :price => 50)
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json?price=eq50", :body => "[#{@ticket.encode}]" )
      @tickets = AthenaTicket.find(:all, :params => {:price => "eq50"})
      @tickets.map { |ticket| ticket.price.should == 50 }
    end
  end

  describe ".destroy" do
    subject { Factory(:ticket_with_id) }

    it "should issue a DELETE when destroying a ticket" do
      FakeWeb.register_uri(:delete, "http://localhost/tix/tickets/#{subject.id}.json", :status => "204")
      subject.destroy

      FakeWeb.last_request.method.should == "DELETE"
      FakeWeb.last_request.path.should == "/tix/tickets/#{subject.id}.json"
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
      FakeWeb.register_uri(:put, "http://localhost/tix/tickets/#{@ticket.id}.json", :body => @ticket.encode)
      @ticket.save

      FakeWeb.last_request.method.should == "PUT"
      FakeWeb.last_request.path.should == "/tix/tickets/#{@ticket.id}.json"
    end

    it "should issue a POST when creating a new AthenaTicket" do
      FakeWeb.register_uri(:post, "http://localhost/tix/tickets/.json", :body => "{}")
      @ticket = Factory.create(:ticket)

      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == "/tix/tickets/.json"
    end
  end

  describe "searching"do
    it "by performance" do
      FakeWeb.register_uri(:get, %r|http://localhost/tix/tickets/.json\?|, :body => "[]")
      now = DateTime.now
      params = { "performance" => "eq#{now.as_json}" }
      AthenaTicket.search(params)
      FakeWeb.last_request.path.should match %r|performance=eq#{CGI::escape now.as_json}|

    end

    it "should add _limit to the query string when included in the arguments" do
      FakeWeb.register_uri(:get, %r|http://localhost/tix/tickets/.json\?_limit=10|, :body => "[]")
      params = { "limit" => "10" }
      AthenaTicket.search(params)
      FakeWeb.last_request.path.should match "_limit=10"
    end

    it "should default to searching for tickets marked as on sale" do
      FakeWeb.register_uri(:get, %r|http://localhost/tix/tickets/.json\?|, :body => "[]")
      AthenaTicket.search({})
      FakeWeb.last_request.path.should match "state=on_sale"
    end
  end

  describe ".to_item" do
    subject { Factory(:ticket_with_id) }
    it "should be a PurchasableTicket" do
      subject.to_item.should be_a PurchasableTicket
    end

    it "should be the right PurchasableTicket" do
      subject.to_item.ticket_id.should eq subject.id.to_i
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

    it { should respond_to :on_sale! }

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

#    it "should not be marked as off sale if it is already sold" do
#      subject.state = "sold"
#      subject.should_not_receive(:save!)
#      subject.off_sale!
#      subject.should be_on_sale
#    end

    it "should return false if it is already sold" do
      subject.state = "sold"
      subject.stub(:save!)
      subject.off_sale!.should be_false
    end
  end

  describe ".sold!" do
    let (:buyer) { Factory(:athena_person_with_id) }
    subject { Factory(:ticket_with_id, :state=>"on_sale") }

    it "should mark the ticket as sold" do
      subject.stub!(:save!)
      subject.sold!(buyer)
      subject.state.should == "sold"
    end

    it "should save the updated ticket" do
      subject.stub!(:save!)
      subject.should_receive(:save!)
      subject.sold!(buyer)
    end

    it "should set the buyer after being sold" do
      subject.stub!(:save!)
      subject.sold!(buyer)
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
end