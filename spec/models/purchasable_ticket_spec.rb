require 'spec_helper'

describe PurchasableTicket do
  subject { Factory(:purchasable_ticket) }

  it { should respond_to :order }
  it { should respond_to :price }
  it { should respond_to :item_id }

  describe ".for" do
    let(:ticket) { Factory(:ticket) }
    subject { PurchasableTicket.for(ticket) }

    it { should be_a PurchasableTicket }

    it "references the ticket passed in" do
      subject.ticket.should eq ticket
    end
  end

  describe "ticket" do
    it { should respond_to :ticket }
    it { should respond_to :ticket_id }

    it "should update the ticket id when updating the ticket" do
      old_id = subject.ticket_id
      new_id = Factory.next(:ticket_id)
      subject.ticket = Factory(:ticket, :id => new_id)
      subject.ticket_id.to_s.should eq new_id
    end

    it "should fetch the ticket from the remote" do
      ticket = Factory(:ticket)
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

    it "should be locked with a valid lock" do
      subject = Factory(:purchasable_ticket, :lock => Factory(:lock))
      subject.should be_locked
    end

    it "should not be locked with an invalid lock" do
      subject = Factory(:purchasable_ticket, :lock => Factory(:expired_lock))
      subject.should_not be_locked
    end

    it "should unlock on destroy if it is not sold" do
      subject.stub!(:unlock)
      subject.should_receive(:unlock)
      subject.destroy
    end

    it "should not unlock on destroy is it is already sold" do
      subject.stub!(:unlock)
      subject.stub(:sold?).and_return(true)
      subject.should_not_receive(:unlock)
      subject.destroy
    end
  end

  describe ".sell_to" do
    it "should delegate sell_to to the ticket" do
      subject.ticket.stub!(:sell_to)
      subject.ticket.should_receive :sell_to
      subject.sell_to(Factory(:person))
    end
  end

  describe ".sold?" do
    it "should delegate sold? to the ticket" do
      subject.ticket.stub!(:sold?)
      subject.ticket.should_receive :sold?
      subject.sold?
    end
  end
end
