require 'spec_helper'

describe Import do

  context "an import with 3 contacts" do
    before do
      @headers = ["First Name", "Last Name", "Email"]
      @rows = [%w(John Doe john@does.com), %w(Jane Wane wane@jane.com), %w(Foo Bar foo@bar.com)]
      @import = FactoryGirl.create(:import)
      @import.stub(:headers) { @headers }
      @import.stub(:rows) { @rows }
      FakeWeb.register_uri(:get, "http://localhost/athena/people.json?_limit=500&_start=0&importId=#{@import.id}", :body => "[]")
      FakeWeb.register_uri(:get, %r{http://localhost/athena/people.json\?email=.*&organizationId=.*}, :body => nil)
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
      @import = FactoryGirl.create(:import, s3_key: @csv_filename)
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

  context "importing event history" do
    context "event-import-no-dollar-amounts.csv" do
      before :each do
        Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  
        @csv_filename = Rails.root.join("spec", "support", "event-import-no-dollar-amounts.csv")
        @import = FactoryGirl.create(:import, s3_key: @csv_filename)
        @import.cache_data
        @import.import
      end
  
      it "should have 6 import rows" do
        @import.import_rows.count.should == 6
      end
      
      it "should have created all the right people" do
        Person.all.length.should eq 6
        Person.where(:first_name => "Monique").where(:last_name => "Meloche").first.should_not be_nil
        Person.where(:first_name => "Dirk").where(:last_name => "Denison").where(:email => "dda@example.com").first.should_not be_nil
        Person.where(:first_name => "James").where(:last_name => "Cahn").where(:email => "jcahn@example.edu").first.should_not be_nil
        Person.where(:first_name => "Susan").where(:last_name => "Goldschmidt").where(:email => "sueg333@example.com").first.should_not be_nil
        Person.where(:first_name => "Plank").where(:last_name => "Goldschmidtt").where(:email => "plank@example.com").first.should_not be_nil
        Person.where(:last_name => "Goldschmidtt").where(:email => "tim@example.com").first.should_not be_nil
      end
    
      it "should create one event, venue for each event. venue in the import file" do
        ["Test Import", "Test Event"].each do |event_name|
          Event.where(:name => event_name).length.should eq 1
          @event = Event.where(:name => event_name).first
          @event.should_not be_nil
          @event.venue.should_not be_nil
          @event.venue.name.should eq "Test Venue"
          @event.organization.should eq @import.organization
          @event.venue.organization.should eq @import.organization
        end
      end  
      
      it "should create shows for each date and attach to the correct event" do
        ["Test Import", "Test Event"].each do |event_name|
          @event = Event.where(:name => event_name).first
          @event.shows.length.should eq 1
          show = @event.shows.first
          show.event.should eq @event
          show.should be_published
        end
      end
        
      it "should create tickets for each person that went to the show" do
        @show = Event.where(:name => "Test Import").first.shows.first
        @show.tickets.length.should eq 4
        @show.tickets.each do |ticket|
          ticket.show.should eq @show
          
          #TODO set buyer id
        end
      end
      
      it "should put a price on the ticket equal to whatever we said int he import file but I forgot the column header and don't have Internet"
    
      it "should create an order for everything, too" do
        Event.where(:name => "Test Import").first.shows.all do |show|
          items = show.items
          items.length.should eq 4
          item.each do |item|
            order = item.order
            (order.is_a? ImportedOrder).should be_true
            
            order.organization.should eq @import.organization
            order.transaction_id.should be_nil
            order.details.should_not be_nil
            
            #TODO: payment_method if applicable
            
            #should be attached to the correct person
            
            
          end
        end
      end
    end
    
    context "#create_show" do
      it "should create shows for each date"
      it "should report an error if show dates are not included"
      it "should report an error if a show date is malformed or unparsable"
    end   
  end
end
