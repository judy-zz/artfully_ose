require 'spec_helper'

describe Address do
  disconnect_sunspot

  let(:keys) { [ :address1, :address2, :city, :state, :zip, :country ] }
  let(:aaaa) { kv = Hash.new; for k in keys do kv[k] = 'a' end; kv }
  let(:bbbb) { kv = Hash.new; for k in keys do kv[k] = 'b' end; kv }
  subject { Factory(:address, aaaa) }
  let(:addra) { Factory(:address, aaaa) }
  let(:addrb) { Factory(:address, bbbb) }

  context "is_same_as()" do
    RSpec::Matchers.define :be_the_same_as do |addr|
      match do |subj|
        subj.is_same_as(addr)
      end
    end

    it "should be true for subject" do
      should be_the_same_as(subject)
    end

    it "should be true for a carbon copy" do
      should be_the_same_as(addra)
    end

    it "should be false for a different address" do
      should_not be_the_same_as(addrb)
    end

    it "should be false for any slightly different address" do
      for key in keys do
        addrx = addra.clone
        addrx[key] = 'x'
        addrx.should be_the_same_as(addrx)
        should_not be_the_same_as(addrx)
      end
    end

  end
end
