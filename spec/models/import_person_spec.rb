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

end
