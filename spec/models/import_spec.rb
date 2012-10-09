require 'spec_helper'

describe Import do

  context "an import with 3 contacts" do
    before do
      @headers = ["First Name", "Last Name", "Email"]
      @rows = [%w(John Doe john@does.com), %w(Jane Wane wane@jane.com), %w(Foo Bar foo@bar.com)]
      @import = FactoryGirl.create(:import)
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
          @import.reload.people.length.should eq 6
          Person.where(:import_id => @import.id).length.should eq 6
        end
      end

      it "should create one event, venue for each event. venue in the import file" do
        imported_events.each do |event|
          Event.where(:name => event.name).length.should eq 1
          event.should_not be_nil
          event.venue.should_not be_nil
          event.venue.name.should eq "Test Venue"
          event.organization.should eq @import.organization
          event.venue.organization.should eq @import.organization
          event.import.should eq @import
        end
      end  
      
      it "should create shows for each date and attach to the correct event" do
        imported_events.each do |event|
          event.shows.length.should eq 1
          show = event.shows.first
          show.event.should eq event
          show.should be_unpublished
        end
      end
        
      it "should create tickets for each person that went to the show" do
        @show = Event.where(:name => "Test Import").first.shows.first
        @show.tickets.length.should eq 4
        @show.tickets.each do |ticket|
          ticket.show.should eq @show
          ticket.section.should_not be_nil
          
          #Weaksauce.  Should be testing for individal buyers
          Person.find(ticket.buyer.id).should_not be_nil
        end
      end
      
      it "should put a price on the ticket"
    
      context "creating orders" do
        before(:each) do
          @orders = []
          imported_events.each do |event|
            event.shows.each do |show|
              show.items.each { |item| @orders << item.order }
            end
          end
          
          @orders.length.should eq 6
        end
      
        it "should create an order for everything, too" do
          @orders.sort_by {|o| o.id}.each_with_index do |order, index|
            order.organization.should eq @import.organization
            order.transaction_id.should be_nil
            order.details.should_not be_nil
            order.import.should eq @import            
            order.payment_method.should   eq target_orders[index].payment_method
            order.person.should           eq target_orders[index].person
          end
        end
        
        it "should create settled items" do
          @orders.each do |order|
            order.items.each {|item| item.should be_settled}
          end
        end
    
        it "should create go and get actions for each person on the order" do
          @import.people.each do |person|
            person.actions.length.should eq 2
            go_action = GoAction.where(:person_id => person.id).first        
            go_action.should_not be nil
            go_action.sentence.should_not be_nil
            go_action.subject.should eq person.orders.first.items.first.show  
            go_action.import.should eq @import 
          end
          
          @orders.each do |order|
            get_action = GetAction.where(:subject_id => order.id).first
            get_action.should_not be nil
            get_action.sentence.should_not be_nil
            get_action.subject.should eq order
            get_action.import.should eq @import 
          end
        end
      end
      
      it "should create shows for each date" do
        imported_shows.length.should eq 2
        imported_shows[0].datetime.should eq DateTime.parse('3/4/2010')
        imported_shows[0].organization.should eq @import.organization
        imported_shows[0].state.should eq "unpublished"
        chart = imported_shows[0].chart
        chart.should_not be_nil
        chart.sections.length.should eq 1
        chart.sections[0].price.should eq 3000
        chart.sections[0].capacity.should eq 4
        
        imported_shows[1].datetime.should eq DateTime.parse('12/12/2011')
        imported_shows[1].organization.should eq @import.organization
        imported_shows[1].state.should eq "unpublished"
        chart = imported_shows[1].chart
        chart.should_not be_nil
        chart.sections.length.should eq 1
        chart.sections[0].price.should eq 0
        chart.sections[0].capacity.should eq 2
      end
    end   
  end
  
  describe "#create_person" do
    before do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
      @headers = ["First Name", "Last Name", "Email"]
      @rows = [%w(John Doe john@does.com)]
      @import = FactoryGirl.create(:import)
      @import.stub(:headers) { @headers }
      @import.stub(:rows) { @rows }
      @existing_person = FactoryGirl.create(:person, :email => "first@example.com")
    end
    
    it "should create the person if the person does not exist" do
      parsed_row = ParsedRow.parse(@headers, @rows.first)
      created_person = @import.create_person(parsed_row)
      created_person.should_not be_new_record
      Person.where(:email => "john@does.com").length.should eq 1
      Person.where(:email => "first@example.com").length.should eq 1
    end
    
    it "should throw an error when a person with an email already exists" do
      @existing_person = FactoryGirl.create(:person, :email => "john@does.com", :organization => @import.organization)
      parsed_row = ParsedRow.parse(@headers, @rows.first)
      failed_person = @import.create_person(parsed_row)
      failed_person.errors.size.should eq 1
      failed_person.should be_new_record
    end
    
    describe "when importing an event" do
      it "should update a person if person already exists" do
        @existing_person = FactoryGirl.create(:person, :email => "john@does.com", :organization => @import.organization)
        parsed_row = ParsedRow.parse(@headers, @rows.first)
        parsed_row.stub(:importing_event?).and_return(true)
        jon = @import.create_person(parsed_row)
        jon.should_not be_new_record
        Person.where(:email => "john@does.com").length.should eq 1
      end
      
      it "should create a new person if necessary" do
        parsed_row = ParsedRow.parse(@headers, @rows.first)
        parsed_row.stub(:importing_event?).and_return(true)
        created_person = @import.create_person(parsed_row)
        created_person.should_not be_new_record
        Person.where(:email => "john@does.com").length.should eq 1
        Person.where(:email => "first@example.com").length.should eq 1
      end
    end
    
    describe "with an external customer id" do
      it "should TODO"
    end
  end
  
  describe "#valid_for_event?" do
    before do
      @import = Import.new
    end
    
    it "should be valid with a show time" do
      @headers = ["First Name", "Last Name", "Email", "Event Name", "Show Date"]
      @rows = [%w(John Doe john@does.com Event1 2012/03/04)]      
      parsed_row = ParsedRow.parse(@headers, @rows.first)
      Import.new.valid_for_event?(parsed_row).should be_true
    end
    
    it "should be valid with a show time" do
      @headers = ["First Name", "Last Name", "Email", "Event Name"]
      @rows = [%w(John Doe john@does.com Event1)]      
      parsed_row = ParsedRow.parse(@headers, @rows.first)
      Import.new.valid_for_event?(parsed_row).should be_false
    end
    
    it "should be valid without an event" do
      @headers = ["First Name", "Last Name", "Email"]
      @rows = [%w(John Doe john@does.com)]      
      parsed_row = ParsedRow.parse(@headers, @rows.first)
      Import.new.valid_for_event?(parsed_row).should be_true
    end
  end
  
  describe "#create_show" do
    before(:each) do
      @headers = ["First Name", "Last Name", "Email", "Event Name", "Show Date"]
      @rows = [%w(John Doe john@does.com Event1 2012/03/04)]      
      @parsed_row = ParsedRow.parse(@headers, @rows.first)
      @event = FactoryGirl.create(:event)
      @import = FactoryGirl.create(:import)
    end
    
    it "should create a show in the unpublished state" do
      show = @import.create_show(@parsed_row, @event)
      show.event.should eq @event
      show.organization.should eq @import.organization
      show.datetime.should eq DateTime.parse("2012/03/04")
      show.should be_unpublished
    end
    
    it "should not create a show if we've already imported a show with that datetime" do      
      existing_show = @import.create_show(@parsed_row, @event)
      show = @import.create_show(@parsed_row, @event)
      show.event.should eq @event
      show.organization.should eq @import.organization
      show.datetime.should eq DateTime.parse("2012/03/04")
      show.should be_unpublished
      show.should eq existing_show
    end
    
    it "should create a show if a show already exists for that time for another event" do
      @headers = ["First Name", "Last Name", "Email", "Event Name", "Show Date"]
      @rows = [%w(John Doe john@does.com Event2 2012/03/04)]      
      @parsed_row = ParsedRow.parse(@headers, @rows.first)
      another_show = @import.create_show(@parsed_row, FactoryGirl.create(:event, :name => "Event2"))
      
      show = @import.create_show(@parsed_row, @event)     
      show.event.should eq @event
      show.organization.should eq @import.organization
      show.datetime.should eq DateTime.parse("2012/03/04")
      show.should be_unpublished
      show.should_not eq another_show
    end
  end
  
  describe "#create_order" do
    before do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    end
    
    before(:each) do
      @headers = ["First Name", "Last Name", "Email", "Event Name", "Show Date", "Amount", "Payment Method"]
      @rows = [%w(John Doe john@does.com Event1 2019/03/04 30 Check)]      
      @parsed_row = ParsedRow.parse(@headers, @rows.first)
      @event = FactoryGirl.create(:event, :name => @parsed_row.event_name)
      @show = FactoryGirl.create(:show, :event => @event, :datetime => DateTime.parse(@parsed_row.show_date))
      @ticket = FactoryGirl.create(:ticket, :show => @show)
      @import = FactoryGirl.create(:import)      
      @person = @import.create_person(@parsed_row)
    end
    
    it "should work without a payment method" do
      @headers = ["First Name", "Last Name", "Email",         "Event Name", "Show Date", "Amount", "Payment Method"]
      @rows =    ["John",       "Doe",       "john@does.com", "Event1",     "2019/03/04","30",     "what"]      
      @parsed_row = ParsedRow.parse(@headers, @rows.first)
      @import = FactoryGirl.create(:import)
      order = @import.create_order(@parsed_row, @person, @event, @show, @ticket)
      order.payment_method.should eq nil
    end
    
    it "should create an order" do
      order = @import.create_order(@parsed_row, @person, @event, @show, @ticket)
      order.organization.should eq @import.organization
      order.items.length.should eq 1
      order.items.first.product.should eq @ticket
      order.items.first.show.should eq @show
      order.person.should eq @person
      order.payment_method.should eq @parsed_row.payment_method
    end
    
    it "should combine orders if an order has the same person and show date as a previous order" do
      existing_order = @import.create_order(@parsed_row, @person, @event, @show, @ticket)
      order = @import.create_order(@parsed_row, @person, @event, @show, @ticket)
      order.should eq existing_order
    end
    
    it "should include the order date"
  end
  
  def imported_shows
    @imported_shows ||= Show.where(:event_id => imported_events).all
  end
  
  def target_orders
    @target_orders ||= build_target_orders
  end
  
  def build_target_orders
    temp_orders = []
    
    temp_orders[0]                  = Order.new
    temp_orders[0].person           = Person.where(:first_name => "Monique").where(:last_name => "Meloche").first
    temp_orders[0].payment_method   = "Cash"
    
    temp_orders[1]                  = Order.new
    temp_orders[1].person           = Person.where(:first_name => "Dirk").where(:last_name => "Denison").where(:email => "dda@example.com").first
    temp_orders[1].payment_method   = "Cash"
    
    temp_orders[2]                  = Order.new
    temp_orders[2].person           = Person.where(:first_name => "James").where(:last_name => "Cahn").where(:email => "jcahn@example.edu").first
    temp_orders[2].payment_method   = "Credit Card"
    
    temp_orders[3]                  = Order.new
    temp_orders[3].person           = Person.where(:first_name => "Susan").where(:last_name => "Goldschmidt").where(:email => "sueg333@example.com").first
    temp_orders[3].payment_method   = "Credit Card"
    
    temp_orders[4]                  = Order.new
    temp_orders[4].person           = Person.where(:first_name => "Plank").where(:last_name => "Goldschmidtt").where(:email => "plank@example.com").first
    temp_orders[4].payment_method   = "Credit Card"
    
    temp_orders[5]                  = Order.new
    temp_orders[5].person           = Person.where(:last_name => "Goldschmidtt").where(:email => "tim@example.com").first
    temp_orders[5].payment_method   = "I.O.U."
    
    temp_orders
  end
  
  def imported_events
    @imported_events ||= Event.where(:name => ["Test Import", "Test Event"]).all
  end
end
