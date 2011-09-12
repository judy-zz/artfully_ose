class FiscallySponsoredProject < ActiveRecord::Base
  belongs_to :organization
  
  def self.from_fractured_atlas(fa_project, organization, fiscally_sponsored_project=nil)
    @fsp = fiscally_sponsored_project || FiscallySponsoredProject.new
    @fsp.fs_project_id = fa_project.id
    @fsp.fa_member_id = fa_project.member_id
    @fsp.name = fa_project.name            
    @fsp.category  = fa_project.category               
    @fsp.profile   = fa_project.profile                       
    @fsp.website = fa_project.website                     
    @fsp.applied_on = fa_project.applied_on                      
    @fsp.status  = fa_project.status
    @fsp.organization = organization
    @fsp
  end
end