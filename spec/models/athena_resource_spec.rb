require 'spec_helper'

describe AthenaResource do
  describe "dynamic_finders" do
    it "should find stuff" do
      t = AthenaTicket.new
      
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets.json?orderId=1", :body=>"")
      o = AthenaOrder.new
      o.id = 1
      AthenaTicket.find_by_order(o)
      
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets.json?orderId=#{o.id}", :body=>"")
      AthenaTicket.find_by_orderId(o.id)
      AthenaTicket.find_by_order_id(o.id)

      FakeWeb.register_uri(:get, "http://localhost/tix/tickets.json?price=50", :body=>"")
      AthenaTicket.find_by_price(50)
    end
  end
end