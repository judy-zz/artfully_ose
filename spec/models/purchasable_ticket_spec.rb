require 'spec_helper'

describe PurchasableTicket do
  subject { Factory(:purchasable_ticket) }

  it { should respond_to :order }
  it { should respond_to :price }
  it { should respond_to :item_id }

  describe "ticket" do
    it { should respond_to :ticket }
    it { should respond_to :ticket_id }

    it "should update the ticket id when updating the ticket" do
      old_id = subject.ticket_id
      subject.ticket = Factory(:ticket, :id => old_id + 1)
      subject.ticket_id.should eq old_id + 1
    end

    it "should fetch the ticket from the remote" do
      ticket = Factory(:ticket_with_id)
      subject.ticket_id = ticket.id
      subject.ticket.should eq ticket
    end
  end

  describe "locking" do
    it { should respond_to :lock }
    it { should respond_to :lock_id }
    it { should respond_to :locked? }

    it "should store a single Lock" do
      @lock = Factory(:lock)
      subject.lock = @lock
      subject.lock.should == @lock
    end

    it "should raise a TypeError when assigning a non-Lock" do
      lambda { subject.lock = 5 }.should raise_error(TypeError, "Expecting an AthenaLock")
    end

    it "should lazy load a Lock from the remote if not set explicitly" do
      lock = Factory(:lock)
      subject = Factory.build(:purchasable_ticket, :lock_id => lock.id)
      subject.lock.should == lock
    end
  end
end
