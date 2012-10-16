require 'spec_helper'

describe DonationsImport do
  context "importing donation history" do
    context "donations-import-full-test.csv" do
      before :each do      
        Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  
        @csv_filename = Rails.root.join("spec", "support", "donations-import-full-test.csv")
        @import = FactoryGirl.create(:donations_import, :organization => FactoryGirl.create(:organization_with_timezone), :s3_key => @csv_filename)
        @import.organization.time_zone = 'Eastern Time (US & Canada)'
        @import.organization.save
        @import.cache_data
        @import.import
      end
  
      #This test can be broken up if we ever get before:all working or something similar  
      it "should do the import" do  
        @import.import_rows.count.should == 3
        Person.where(:import_id => @import.id).length.should eq 3
        Person.where(:first_name => "Cal").where(:last_name => "Ripken").where(:email => "calripken@example.com").first.should_not be_nil
        Person.where(:first_name => "Adam").where(:last_name => "Jones").where(:email => "adamjones10@example.com").first.should_not be_nil
        Person.where(:first_name => "Mark").where(:last_name => "Cuban").where(:email => nil).first.should_not be_nil
        ImportedOrder.where(:import_id => @import.id).length.should eq 3
        GiveAction.where(:import_id => @import.id).length.should eq 3
      end
    end   
  end
  
  describe "#create_donation" do
    before(:each) do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    end
    
    it "should create the donation and underlying action" do
      @headers = ["Email","First","Last","Date","Payment Method","Donation Type","Donation Amount"]
      @rows = ["calripken@example.com","Cal","Ripken","3/4/2010","Other","In-Kind","50.00"]      
      @parsed_row = ParsedRow.parse(@headers, @rows)
      @import = FactoryGirl.create(:donations_import)          
      @import.organization.time_zone = 'Eastern Time (US & Canada)'
      @import.organization.save   
      @person = @import.create_person(@parsed_row)
      
      contribution = @import.create_contribution(@parsed_row, @person)
      order  = contribution.order
      order.person.should eq @person
      order.organization.should eq @import.organization
      order.items.length.should eq 1
      order.items.first.price.should eq 5000
      order.items.first.realized_price.should eq 5000
      order.items.first.net.should eq 5000
      order.items.first.should be_settled
      
      action = contribution.action
      (action.is_a? GiveAction).should be_true
      action.subject.should eq order
      action.person.should eq @person
      action.import.should eq @import
      action.subtype.should eq @parsed_row.donation_type
      action.details.should_not be_nil
      action.creator.should_not be_nil
    end
    
    it "should accept nongift amounts" do
      @headers = ["Email","First","Last","Date","Payment Method","Donation Type","Donation Amount", "Non-Deductible Amount"]
      @rows = ["calripken@example.com","Cal","Ripken","3/4/2010","Other","In-Kind","50.00", "1.23"]      
      @parsed_row = ParsedRow.parse(@headers, @rows)
      @import = FactoryGirl.create(:donations_import)          
      @import.organization.time_zone = 'Eastern Time (US & Canada)'
      @import.organization.save   
      @person = @import.create_person(@parsed_row)
      
      contribution = @import.create_contribution(@parsed_row, @person)
      order  = contribution.order
      order.person.should eq @person
      order.organization.should eq @import.organization
      order.items.length.should eq 1
      order.items.first.price.should eq 5000
      order.items.first.realized_price.should eq 5000
      order.items.first.net.should eq 5000
      order.items.first.nongift_amount.should eq 123
      order.items.first.total_price.should eq 5123
      order.items.first.should be_settled
    end
    
    it "should set occurred_at to today if date doesn't exist" do
      @headers = ["Email","First","Last","Payment Method","Donation Type","Donation Amount"]
      @rows = ["calripken@example.com","Cal","Ripken","Other","In-Kind","50.00"]      
      @parsed_row = ParsedRow.parse(@headers, @rows)
      @import = FactoryGirl.create(:donations_import)          
      @import.organization.time_zone = 'Eastern Time (US & Canada)'
      @import.organization.save   
      @person = @import.create_person(@parsed_row)
      
      contribution = @import.create_contribution(@parsed_row, @person)
      order  = contribution.order
      order.created_at.should be_today
      action = contribution.action
      action.occurred_at.should be_today
    end
  end
  
  describe "#row_valid" do
    it "should be invalid without an amount" do
      @headers = ["Email","First","Last","Payment Method","Donation Type"]
      @rows = ["calripken@example.com","Cal","Ripken","Other","In-Kind"]      
      @parsed_row = ParsedRow.parse(@headers, @rows)
      DonationsImport.new.row_valid?(@parsed_row).should be_false
    end
  end
end