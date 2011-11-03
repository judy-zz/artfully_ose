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

  describe "#clean_phone" do
    it "formats a phone number without any formatting" do
      subject.phone = "5712417836"
      subject.clean_phone
      subject.phone.should eq "571-241-7836"
    end

    it "formats a phone number with alternative formatting" do
      [ "571.241.7836", "(571)2417836", "(571)-241-7836", "571 241 7836" ].each do |number|
        subject.phone = number
        subject.clean_phone
        subject.phone.should eq "571-241-7836"
      end
    end
  end

  describe "#valid?" do
    it { should be_valid }

    it "isn't valid if the account type is not Personal Checking or Personal Savings" do
      subject.account_type = "Mutual Fund"
      subject.should_not be_valid
    end
  end
end
