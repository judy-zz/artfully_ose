require 'spec_helper'
require 'active_merchant_test_helper'

class MockPayment < Payment
  payment_method :mock_mock
  attr_accessor :my_var
  
  def initialize(params = {})
    self.my_var = params[:a]
  end
end

describe Payment do
  
  describe "#create" do
    it "should create the correct instance form a type" do
      assert (Payment.create :mock_mock).class.name == "MockPayment"
    end
    
    it "should raise an error if the type is unknown" do
      lambda { Payment.create :unknown_type }.should raise_error 
    end
    
    it "should report the payment type" do
      MockPayment.new.payment_method.should eq "Mock mock"
    end
    
    it "should pass options through to the subclass" do
      mock_mock = Payment.create(:mock_mock, {:a => "b"})
      mock_mock.my_var.should eq "b"
    end
  end
end