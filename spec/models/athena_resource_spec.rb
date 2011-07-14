require 'spec_helper'

describe AthenaResource do
  describe "dynamic_finders" do
    it "should find stuff" do
      FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?orderId=1", :body=>"")
      AthenaTicket.find_by_order_id(1)

      FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?price=50", :body=>"")
      AthenaTicket.find_by_price(50)
    end
  end
end