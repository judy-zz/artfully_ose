require 'spec_helper'

describe BankAccount do
  subject { Factory(:bank_account) }

  describe "#customer_information" do
    let(:customer_info) { subject.customer_information }

    it "creates a hash with the customer's personal information" do
      [:name, :address, :city, :state, :zip, :phone].each do |attribute|
        customer_info[attribute].should eq subject.send(attribute)
      end
    end
  end

  describe "#account_information" do
    let(:account_information) { subject.account_information }
    it "creates a hash with the customer's bank account information" do
      [:routing_number, :number, :account_type].each do |attribute|
        account_information[attribute].should eq subject.send(attribute)
      end
    end
  end
end
