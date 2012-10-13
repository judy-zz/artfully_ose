require 'spec_helper'

describe PeopleImport do
  context "an import with 3 contacts" do
    before do
      @headers = ["First Name", "Last Name", "Email"]
      @rows = [%w(John Doe john@does.com), %w(Jane Wane wane@jane.com), %w(Foo Bar foo@bar.com)]
      @import = FactoryGirl.create(:people_import)
      @import.stub(:headers) { @headers }
      @import.stub(:rows) { @rows }
    end
  
    it "should import a total of three records" do
      @person = Person.new
      @person.stub(:save).and_return(true)
      @address = Address.new
      @address.stub(:save).and_return(true)
      @import.should_receive(:attach_person).exactly(3).times.and_return(@person)
      @import.import
      @import.import_errors.should be_empty
    end
  end

  context "an example import from a customer" do
    before :each do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  
      @csv_filename = Rails.root.join("spec", "support", "patron-import.csv")
      @import = FactoryGirl.create(:people_import, s3_key: @csv_filename)
      @import.cache_data
      @import.import
    end
  
    it "should have 359 import rows" do
      @import.import_rows.count.should == 358
    end
  
    it "should successfully import 0 people" do
      Person.count.should == 0
    end
  
    it "should be failed" do
      @import.status.should == "failed"
    end
  
    it "should have 2 duplicate email errors" do
      @import.import_errors.count.should == 2
      @import.import_errors.map(&:error_message).uniq.should == [ "Email has already been taken" ]
    end
  end
  
  describe "#create_person" do
    before do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
      @headers = ["First Name", "Last Name", "Email", "Company"]
      @rows = [%w(John Doe john@does.com Bernaduccis)]
      @import = FactoryGirl.create(:people_import)
      @import.stub(:headers) { @headers }
      @import.stub(:rows) { @rows }
      @existing_person = FactoryGirl.create(:person, :email => "first@example.com")
    end
    
    it "should create the person if the person does not exist" do
      parsed_row = ParsedRow.parse(@headers, @rows.first)
      created_person = @import.create_person(parsed_row)
      created_person.should_not be_new_record
      created_person.first_name.should eq "John"
      created_person.last_name.should eq "Doe"
      created_person.email.should eq "john@does.com"
      created_person.company_name.should eq "Bernaduccis"
      Person.where(:email => "john@does.com").length.should eq 1
      Person.where(:email => "first@example.com").length.should eq 1
    end
    
    it "sets the address on the person"
    
    it "should throw an error when a person with an email already exists" do
      @existing_person = FactoryGirl.create(:person, :email => "john@does.com", :organization => @import.organization)
      parsed_row = ParsedRow.parse(@headers, @rows.first)
      failed_person = @import.create_person(parsed_row)
      failed_person.errors.size.should eq 1
      failed_person.should be_new_record
    end
  end
end