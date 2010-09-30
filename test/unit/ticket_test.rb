require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  setup do
    FakeWeb.register_uri(:get, 'http://localhost/tickets/1', :body => "{}")
  end

  context "An existing ticket" do
    should "be fetchable by id" do
      FakeWeb.register_uri(:get, 'http://localhost/tickets/1', :body => "{}")
      @ticket = Ticket.find(1)
      assert @ticket.valid?
    end
  end
end
