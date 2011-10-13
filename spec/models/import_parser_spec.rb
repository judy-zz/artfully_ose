require 'spec_helper'

describe ImportParser do

  context "a very simple csv file" do
    before do
      @csv_data = "NUMBER\n1\n2\n3\n"
      @parser = ImportParser.new(@csv_data)
    end

    it "should have valid headers" do
      @parser.headers.should == ["NUMBER"]
    end

    it "should have the correct content" do
      @parser.to_a.should == [["1"], ["2"], ["3"]]
    end
  end

  context "a csv file with multiple columns" do
    before do
      @csv_data = %["First Column",Second,"My Third"\nA great one,"Another good one",Not so hot]
      @parser = ImportParser.new(@csv_data)
    end

    it "should have valid headers" do
      @parser.headers.should == ["First Column", "Second", "My Third"]
    end

    it "should have the correct content" do
      @parser.to_a.should == [["A great one", "Another good one", "Not so hot"]]
    end
  end

  context "a csv file with escaped data" do
    before do
      @csv_data = %["My ""Column""",Two\n"What's up, doc?","Nothing ""\nmuch"""\n1,2]
      @parser = ImportParser.new(@csv_data)
    end

    it "should have correct headers" do
      @parser.headers.should == ['My "Column"', 'Two']
    end

    it "should have correct content" do
      @parser.to_a.should == [["What's up, doc?", %[Nothing "\nmuch"]], ["1", "2"]]
    end
  end

end
