require 'spec_helper'

describe Import do

  context "an import with 3 contacts" do
    before do
      @headers = ["First Name", "Last Name", "Email"]
      @rows = [%w(John Doe john@does.com), %w(Jane Wane wane@jane.com), %w(Foo Bar foo@bar.com)]
      @import = Factory.create(:import)
      @import.stub(:headers) { @headers }
      @import.stub(:rows) { @rows }
      FakeWeb.register_uri(:get, "http://localhost/athena/people.json?_limit=500&_start=0&importId=#{@import.id}", :body => "[]")
      FakeWeb.register_uri(:get, %r{http://localhost/athena/people.json\?email=.*&organizationId=.*}, :body => nil)
    end

    it "should import a total of three records" do
      @person = AthenaPerson.new
      @person.stub(:save).and_return(true)
      @address = Address.new
      @address.stub(:save).and_return(true)
      @import.should_receive(:attach_person).exactly(3).times.and_return(@person)
      @import.should_receive(:attach_address).exactly(3).times.and_return(@address)
      @import.perform
      @import.import_errors.should be_empty
    end
  end

end
