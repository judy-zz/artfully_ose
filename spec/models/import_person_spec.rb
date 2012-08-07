require 'spec_helper'

describe ImportPerson do

  context "a person with their email and company specified" do
    before do
      @headers = [ "EMAIL", "Company" ]
      @row = [ "test@artful.ly", "Fractured Atlas" ]
      @person = ImportPerson.new(@headers, @row)
    end
  
    it "should have the correct email" do
      @person.email.should == "test@artful.ly"
    end
  
    it "should have the correct company" do
      @person.company.should == "Fractured Atlas"
    end
  
    it "should have a nil name" do
      @person.first.should be_nil
    end
  end
  
  context "a person with tags" do
    before do
      @headers = [ "Tags" ]
      @row = [ "one|two,three four" ]
      @person = ImportPerson.new(@headers, @row)
    end
  
    it "should correctly split on spaces, bars or commas" do
      @person.tags_list.should == %w( one two three-four )
    end
  end

  context "a person with a type" do
    before do
      @headers = [ "Person Type" ]
      @types = [ "individual", "corporation", "FOUNDATION", "GovernMENT", "nonsense", "other" ]
      @people = @types.map { |type| ImportPerson.new(@headers, [type]) }
    end
  
    it "should correctly load the enumerated types" do
      @people.map(&:person_type).should == %w( Individual Corporation Foundation Government Other Other )
    end
  end

end
