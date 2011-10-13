require 'spec_helper'

describe Import do

  context "an import with a simple document" do
    before do
      @import = Import.new
      @import.stub!(:csv_data).and_return("Email,First\ntest@artful.ly,Test Man")
    end

    it "should have one imported record" do
      @import.parser.count.should == 1
    end

    it "should have a record imported with the correct email" do
      @import.parser.first.email.should == "test@artful.ly"
    end
  end

end
