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
    context "event-import-full-test.csv" do
      before :each do
        Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  
        @csv_filename = Rails.root.join("spec", "support", "event-import-full-test.csv")
        @import = FactoryGirl.create(:import, s3_key: @csv_filename)
        @import.cache_data
        @import.import
      end
  
      it "should have 6 import rows" do
        @import.import_rows.count.should == 6
      end
      
      context "creating people" do
        it "should create six people" do
          Person.all.length.should eq 6
          Person.where(:first_name => "Monique").where(:last_name => "Meloche").first.should_not be_nil
          Person.where(:first_name => "Dirk").where(:last_name => "Denison").where(:email => "dda@example.com").first.should_not be_nil
          Person.where(:first_name => "James").where(:last_name => "Cahn").where(:email => "jcahn@example.edu").first.should_not be_nil
          Person.where(:first_name => "Susan").where(:last_name => "Goldschmidt").where(:email => "sueg333@example.com").first.should_not be_nil
          Person.where(:first_name => "Plank").where(:last_name => "Goldschmidtt").where(:email => "plank@example.com").first.should_not be_nil
          Person.where(:last_name => "Goldschmidtt").where(:email => "tim@example.com").first.should_not be_nil
        end
        
        it "should attach the import to the people" do
          @import.people.length.should eq 6
          Person.where(:import_id => @import.id).length.should eq 6
        end
      end
      
      context "creating actions" do   
        it "should create go and get actions for each person on the order" do
          @import.people.each do |person|
            person.actions.length.should eq 2
            go_action = GoAction.where(:person_id => person.id).first        
            go_action.should_not be nil
            go_action.sentence.should_not be_nil
            go_action.subject.should eq person.orders.first.items.first.show   
        
            get_action = GetAction.where(:person_id => person.id).first
            get_action.should_not be nil
            get_action.sentence.should_not be_nil
            go_action.subject.should eq person.orders.first.items.first.show
          end
        end
        
        #TODO: Actions tagged with import_id?
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
      
      it "should put a price on the ticket" do
        
      end
    
      context "creating orders" do
        before(:each) do
          @orders = []
          ["Test Import", "Test Event"].each do |event_name|
            Event.where(:name => event_name).first.shows.each do |show|
              items = show.items
              items.each do |item|
                @orders << item.order
              end
            end
          end
          
          @orders.length.should eq 6
        end
      
        it "should create an order for everything, too" do
          @orders.each do |order|
            order.organization.should eq @import.organization
            order.transaction_id.should be_nil
            order.details.should_not be_nil
          
            #TODO: payment_method if applicable
          
            #should be attached to the correct person
          end
        end
        
        it "should be attached to the import"
      end
    end
    
    context "#create_show" do
      it "should create shows for each date"
      it "should report an error if show dates are not included"
      it "should report an error if a show date is malformed or unparsable"
    end   
  end
end
