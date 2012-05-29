require 'spec_helper'

describe Person do
  disconnect_sunspot
  subject { Factory(:person) }

  it "should accept a note" do
    subject.notes.length.should eq 0
    subject.notes.build(:text => "This is my first note.")
    subject.save
    subject.notes.length.should eq 1
  end
  
  describe "adding phone number" do
    before(:each) do
      subject.phones.create(:number => "333-333-3333")
      subject.phones.create(:number => "444-444-4444")
    end
    
    it "should add the number" do
      subject.add_phone_if_missing("555-555-5555")
      subject.phones.length.should eq 3
      subject.phones.last.number.should eq "555-555-5555"
      subject.phones.last.kind.should eq "Other"
    end
    
    it "shouldn't add a nnumber if it already exists" do
      subject.add_phone_if_missing("444-444-4444")
      subject.phones.length.should eq 2
      subject.phones.first.number.should eq "333-333-3333"
      subject.phones.last.number.should eq "444-444-4444"
    end
  end
  
  describe "mergables" do
    
    let(:exceptions) { [:taggings, :base_tags, :tag_taggings, :tags, :tickets] }
    
    #This test is more of a reminder that when person gets a new has_many, it should
    #either be excluded explicitly here, or added to mergables
    it "should include all has_many associations excluding exceptions" do
      @has_manys= Person.reflect_on_all_associations.select{|d| d.macro == :has_many}
      @has_manys.reject! {|m| exceptions.include? m.name}
      @has_many_names = []
      @has_manys.collect {|m| @has_many_names << m.name}
      Person.mergables.should eq @has_many_names
    end
  end
  
  describe "#find_by_customer" do
    let(:organization) { Factory(:organization) }
    it "should find by person_id if one is present" do
      customer = AthenaCustomer.new({
        :person_id => subject.id,
        :email => "person@example.com",
        :organization_id => organization.id
      })
      Person.should_receive(:find).with(customer.person_id)
      p = Person.find_or_create(customer, organization)
    end
    
    it "should find by email and org if no person_id is present" do
      customer = AthenaCustomer.new({
        :email => "person@example.com",
        :organization_id => organization.id
      })
      params = {
        :email => "person@example.com",
        :organization_id => organization.id
      }
      Person.should_not_receive(:find).with(customer.person_id)
      Person.should_receive(:find).with(:first, :conditions => params)
      p = Person.find_or_create(customer, organization)
    end
    
    it "should return a new person if no person_id or email is provided" do
      customer = AthenaCustomer.new({
        :organization_id  => organization.id,
        :first_name       => "Russian"
      })
      params = {
        :organization_id => organization.id,
        :first_name       => "Russian"
      }
      Person.should_not_receive(:find).with(customer.person_id)
      Person.should_not_receive(:find).with(:first, :conditions => params)
      p = Person.find_or_create(customer, organization)
      p.first_name.should         eq  customer.first_name
      p.organization.id.should    eq  organization.id
      p.last_name.should          be_nil
      p.email.should              be_nil
    end
  end
  
  describe "merging" do
    describe "different orgs" do   
      before(:each) do
        @winner = Factory(:person, :organization => Factory(:organization))
        @loser = Factory(:person, :organization => Factory(:organization))
      end
       
      it "should throw an exception if the two person records are in different orgs" do
        lambda { Person.merge(@winner, @loser) }.should raise_error
      end
    end
    
    describe "a happier path" do
      before(:each) do
        @organization = Factory(:organization)
        @winner = Factory(:person, :organization => @organization)
        @winner.actions << Factory(:get_action, :person => @winner)
        @winner.orders  << Factory(:order, :person => @winner)
        @winner.tickets << Factory(:ticket, :buyer => @winner)
        @winner.notes.build(:text => 'winner')
        @winner.phones.build({:kind => 'Work', :number=>'1234567890'})
        @winning_address = Factory(:address, :person => @winner)
        @winner.address = @winning_address
        @winner.tag_list = 'east, west'
        @winner.save
        
        @loser = Factory(:person, :organization => @organization)
        @loser.actions << Factory(:get_action, :person => @loser)
        @loser.orders  << Factory(:order, :person => @loser)
        @loser.tickets << Factory(:ticket, :buyer => @loser)
        @loser.notes.build(:text => 'loser')
        @loser.phones.build({:kind => 'Cell', :number=>'3333333333'})
        @losing_address = Factory(:address, :person => @loser)
        @loser.address = @losing_address
        @loser.tag_list = 'west, north, south'
        @loser.save
        
        @merge_result = Person.merge(@winner, @loser)
      end
    
      it "should return the winner" do
        @merge_result.id.should eq @winner.id
      end
    
      it "should merge the losers's actions into the winner's" do    
        @merge_result.actions.length.should eq 2
        @merge_result.actions.each do |action|
          action.person.should eq @merge_result
        end
      end
    
      it "should merge the loser's notes into the winner's" do  
        @merge_result.notes.length.should eq 2
        @merge_result.notes.each do |note|
          note.person.should eq @merge_result
        end
      end
      
           
      it "should change the loser's orders into the winner's" do
        @merge_result.orders.length.should eq 2
        @merge_result.orders.each do |order|
          order.person.should eq @merge_result
        end
      end
           
      it "should change the loser's tickets into the winner's" do
        @merge_result.tickets.length.should eq 2
        @merge_result.tickets.each do |ticket|
          ticket.buyer.should eq @merge_result
        end
      end
           
      it "should merge the phones" do
        @winner.phones.length.should eq 2
        @winner.phones[0].kind.should eq 'Work'
        @winner.phones[0].number.should eq '1234567890'
        @winner.phones[1].kind.should eq 'Cell'
        @winner.phones[1].number.should eq '3333333333'
      end
           
      it "should paranoid delete the loser" do
        ::Person.unscoped.find(@loser.id).deleted_at.should_not be_nil
      end
           
      it "should not change the winner's address" do
        @winner.address.should eq @winning_address
      end
      
      it "should merge the tags" do
        @winner.tag_list.should include('east')
        @winner.tag_list.should include('west')
        @winner.tag_list.should include('north')
        @winner.tag_list.should include('south')
        @winner.tag_list.length.should eq 4
      end
    end
  end
  
  context "updating address" do
    let(:addr1)     { Address.new(:address1 => '123 A St.') }
    let(:addr2)     { Address.new(:address1 => '234 B Ln.') }
    let(:user)      { User.create() }
    let(:time_zone) { ActiveSupport::TimeZone["UTC"] }
  
    it "should create address when none exists, and add note" do
      num_notes = subject.notes.length
      subject.address.should be_nil
      subject.update_address(addr1, time_zone, user).should eq true
      subject.address.should_not be_nil
      subject.address.to_s.should eq addr1.to_s
      subject.notes.length.should eq num_notes + 1
      Address.all.length.should eq 1
    end
  
    it "should not update when nil address supplied" do
      num_notes = subject.notes.length
      old_addr = subject.address.to_s
      subject.update_address(nil, time_zone, user).should eq true
      subject.address.to_s.should eq old_addr
      subject.notes.length.should eq num_notes
    end
  
    it "should not update when address is unchanged" do
      subject.update_address(addr1, time_zone, user).should eq true
      num_notes = subject.notes.length
      old_addr = subject.address.to_s
      subject.update_address(addr1, time_zone, user).should eq true
      subject.address.to_s.should eq old_addr
      subject.notes.length.should eq num_notes
    end
  
    it "should update address when address is changed, and add note" do
      subject.update_address(addr1, time_zone, user).should eq true
      num_notes = subject.notes.length
      subject.update_address(addr2, time_zone, user).should eq true
      subject.address.to_s.should eq addr2.to_s
      subject.notes.length.should eq num_notes + 1
    end
  
    it "should allow a note with nil user" do
      num_notes = subject.notes.length
      subject.update_address(addr1, time_zone).should eq true
      subject.address.to_s.should eq addr1.to_s
      subject.notes.length.should eq num_notes + 1
    end
  end
  
  describe "#valid?" do
  
    it { should be_valid }
    it { should respond_to :email }
  
    it "should be valid with one of the following: first name, last name, email" do
      subject.email = 'something@somewhere.com'
      subject.first_name = nil
      subject.last_name = nil
      subject.should be_valid
  
      subject.email = nil
      subject.first_name = 'First!'
      subject.last_name = nil
      subject.should be_valid
  
      subject.email = nil
      subject.first_name = nil
      subject.last_name = 'Band'
      subject.should be_valid
  
      subject.email = nil
      subject.first_name = ''
      subject.last_name = 'Band'
      subject.should be_valid
    end
  
    it "should not be valid without a first name, last name or email address" do
      subject.first_name = nil
      subject.last_name = nil
      subject.email = nil
      subject.should_not be_valid
    end
  end
  
  describe "#find_by_email_and_organization" do
    let(:organization) { Factory(:organization) }
  
    before(:each) do
      Person.stub(:find).and_return
    end
  
    it "should search for the Person by email address and organization" do
      params = {
        :email => "person@example.com",
        :organization_id => organization.id
      }
      Person.should_receive(:find).with(:first, :conditions => params)
      Person.find_by_email_and_organization("person@example.com", organization)
    end
  
    it "should return nil if it doesn't find anyone" do
      email = "person@example.com"
      p = Person.find_by_email_and_organization(email, organization)
      p.should eq nil
    end
    
    it "should return nil if the email address is nil" do
      p = Factory(:person_without_email, :organization => organization)
      Person.find_by_email_and_organization(nil, organization).should be_nil
    end
  end
  
  describe "organization" do
    it { should respond_to :organization }
    it { should respond_to :organization_id }
  end
  
  describe "uniqueness" do
    subject { Factory.build(:person) }
    it "should not be valid if another person record exists with that email for the organization" do
      Factory(:person, :email => subject.email, :organization => subject.organization)
      subject.should_not be_valid
    end
  end
  
  describe "#dummy_for" do
    let(:organization) { Factory(:organization) }
    it "fetches the dummy record for the organization" do
      person = Person.dummy_for(organization)
      Person.dummy_for(organization).should eq person
    end
  
    it "creates the dummy record if one does not yet exist" do
      person = Person.dummy_for(organization)
      person.dummy.should be_true
    end
  end

end
