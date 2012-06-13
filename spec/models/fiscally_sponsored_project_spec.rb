require 'spec_helper'

describe FiscallySponsoredProject do
  subject { Factory(:fiscally_sponsored_project) }

  let(:fa_project){ Factory.build(:fa_project) }
  let(:organization){ Factory(:organization) }

  describe ".attributes_from" do
    subject { FiscallySponsoredProject.attributes_from(fa_project)}

    it "returns a hash with the appropriate mapping" do
      subject[:fs_project_id].should == fa_project.id
      subject[:fa_member_id].should  == fa_project.member_id
      subject[:name].should          == fa_project.name
      subject[:category].should      == fa_project.category
      subject[:profile].should       == fa_project.profile
      subject[:website].should       == fa_project.website
      subject[:applied_on].should    == DateTime.parse(fa_project.applied_on)
      subject[:status].should        == fa_project.status
    end
  end

  describe "#refresh" do
    it "fetches the latest project from Fractured Atlas" do
      FA::Project.should_receive(:find_active_by_member_id).and_return(fa_project)
      subject.refresh
    end
    
    it "updates the updated_at on each refresh regardless if the attributes were updated" do
      FA::Project.should_receive(:find_active_by_member_id).twice.and_return(fa_project)
      subject.refresh
      @first_refresh = subject.updated_at
      sleep 2
      subject.refresh
      subject.updated_at.should > @first_refresh
    end

    it "does not update attributes if the remote project is not found" do
      FA::Project.stub(:find_active_by_member_id).and_raise(ActiveResource::ResourceNotFound.new("Not Found"))
      subject.should_not_receive(:update_attributes)
      lambda { subject.refresh }.should_not raise_error(ActiveResource::ResourceNotFound.new("Not Found"))
    end
  end

  describe "#active?" do
    it "is not active when the status of the project is anything other than \"Active\"" do
      subject.status = "Terminated"
      subject.should_not be_active
      subject.status = ""
      subject.should_not be_active
      subject.status = nil
      subject.should_not be_active
    end

    it "is active when the status is \"Active\"" do
      subject.status = "Active"
      subject.should be_active
    end
  end
end