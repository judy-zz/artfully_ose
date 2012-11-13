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
        Person.where(:import_id => @import.id).length.should eq 3
        Person.where(:first_name => "Cal").where(:last_name => "Ripken").where(:email => "calripken@example.com").first.should_not be_nil
        Person.where(:first_name => "Adam").where(:last_name => "Jones").where(:email => "adamjones10@example.com").first.should_not be_nil
        Person.where(:first_name => "Mark").where(:last_name => "Cuban").where(:email => nil).first.should_not be_nil
        ImportedOrder.where(:import_id => @import.id).length.should eq 3
        GiveAction.where(:import_id => @import.id).length.should eq 3
        @import.import_rows.count.should == 3
      end
    end   
  end
  
  describe "#rollback" do
    it "should clean up the people, orders, items" do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
      @csv_filename = Rails.root.join("spec", "support", "donations-import-full-test.csv")
      @import = FactoryGirl.create(:donations_import, :organization => FactoryGirl.create(:organization_with_timezone), :s3_key => @csv_filename)
      @import.organization.time_zone = 'Eastern Time (US & Canada)'
      @import.organization.save
      @import.cache_data
      @import.import
      
      items = []
      ImportedOrder.where(:import_id => @import.id).all.collect { |o| items = items + o.items.all }
      
      @import.rollback
      Person.where(:import_id => @import.id).all.should be_empty
      ImportedOrder.where(:import_id => @import.id).all.should be_empty
      items.each do |i|
        Item.where(:id => i.id).all.should be_empty
      end
      Action.where(:import_id => @import.id).all.should be_empty
    end
  end
  
  describe "#create_donation" do
    before(:each) do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    end
    
    it "should create the donation and underlying action" do
      @headers = ["Email","First","Last","Date","Payment Method","Donation Type","Deductible Amount"]
      @rows = ["calripken@example.com","Cal","Ripken","3/4/2010","Check","In-Kind","50.00"]      
      @parsed_row = ParsedRow.parse(@headers, @rows)
      @import = FactoryGirl.create(:donations_import)          
      @import.organization.time_zone = 'Eastern Time (US & Canada)'
      @import.organization.save   
      @person = @import.create_person(@parsed_row)
      
      contribution = @import.create_contribution(@parsed_row, @person)
      order  = contribution.order
      order.person.should eq @person
      order.organization.should eq @import.organization
      order.payment_method.should eq "Check"
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
      @headers = ["Email","First","Last","Date","Payment Method","Donation Type","Deductible Amount", "Non-Deductible Amount"]
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
      @headers = ["Email","First","Last","Payment Method","Donation Type","Deductible Amount"]
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
  
  describe "#create_person" do
    before do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
      @headers = ["Email","First","Last","Payment Method","Donation Type","Deductible Amount"]
      @rows = ["john@does.com","Cal","Ripken","Other","In-Kind","50.00"] 
      @import = FactoryGirl.create(:donations_import)
      @import.stub(:headers) { @headers }
      @import.stub(:rows) { @rows }
      @existing_person = FactoryGirl.create(:person, :email => "first@example.com")
    end
    
    it "should update a person if person already exists" do
      @existing_person = FactoryGirl.create(:person, :email => "john@does.com", :organization => @import.organization)
      parsed_row = ParsedRow.parse(@headers, @rows)
      parsed_row.stub(:importing_event?).and_return(true)
      jon = @import.create_person(parsed_row)
      jon.should_not be_new_record
      jon.import.should be nil
      Person.where(:email => "john@does.com").length.should eq 1
    end
    
    it "should create a new person if necessary" do
      parsed_row = ParsedRow.parse(@headers, @rows)
      parsed_row.stub(:importing_event?).and_return(true)
      created_person = @import.create_person(parsed_row)
      created_person.should_not be_new_record
      Person.where(:email => "john@does.com").length.should eq 1
      Person.where(:email => "first@example.com").length.should eq 1
    end
    
    it "should save a new person even if there's no email" do
      @headers = ["First Name", "Email", "Last Name", "Event Name", "Company"]
      @rows = ["John",nil,"Doe", "Duplicate People", "Bernaduccis"]
      parsed_row = ParsedRow.parse(@headers, @rows)
      person = @import.create_person(parsed_row)
      person.should_not be_nil
      person.first_name.should eq "John"
      person.last_name.should eq "Doe"
      person.email.should be_nil
      person.company_name.should eq "Bernaduccis"       
    end
      
    it "should attach the additional people information" do
      @headers = ["First Name", "Email", "Last Name", "Event Name", "Company", "Tags"]
      @rows = ["John",nil,"Doe", "Duplicate People", "Bernaduccis", "Attendee"]
      parsed_row = ParsedRow.parse(@headers, @rows)
      person = @import.create_person(parsed_row)
      person = Person.find(person.id)
      person.company_name.should eq "Bernaduccis"
      person.tag_list.length.should be 1     
    end
      
    it "should not use existing people with no email" do
      @no_email = FactoryGirl.create(:person, :first_name => "No", :last_name => "Email", :organization => @import.organization)
      @no_email.email = nil
      @no_email.save
      @headers = ["First Name", "Email", "Last Name", "Event Name", "Company"]
      @rows = ["John",nil,"Doe", "Duplicate People", "Bernaduccis"]
      parsed_row = ParsedRow.parse(@headers, @rows)
      person = @import.create_person(parsed_row)
      person.company_name.should eq "Bernaduccis"
      person.id.should_not eq @no_email.id        
    end
    
    describe "with an external customer id"
  end
  
  describe "#row_valid" do
    it "should raise an error if there is no deductible amount" do
      @headers = ["Email","First","Last","Payment Method","Donation Type","Deductible Amount"]
      @rows = ["calripken@example.com","Cal","Ripken","Other","In-Kind",""]    
      @import = FactoryGirl.create(:donations_import) 
      lambda { @import.process(ParsedRow.new(@headers, @rows)) }.should raise_error Import::RowError
    end
  end
end