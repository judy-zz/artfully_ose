require 'spec_helper'

describe FiscallySponsoredProject do
  subject { Factory(:fiscally_sponsored_project) }
  
  describe "initializing from fa_project" do
    it "should create itself from a valid project" do
      fa_project = Factory(:fa_project)
      organization = Factory(:organization_with_id)
      subject = FiscallySponsoredProject.from_fractured_atlas(fa_project, organization, subject)
      subject.fs_project_id.should eq fa_project.id
      subject.fa_member_id.should eq fa_project.member_id
      subject.name.should eq fa_project.name            
      subject.category.should eq fa_project.category               
      subject.profile.should eq fa_project.profile                       
      subject.website.should eq fa_project.website                     
      subject.applied_on.should eq DateTime.parse fa_project.applied_on                      
      subject.status.should eq fa_project.status
      subject.organization.should eq organization
    end
  end
end