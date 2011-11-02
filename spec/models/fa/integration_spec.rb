require 'spec_helper'

describe FA::Integration do
    context "integration" do
      before(:each) do
        @user = Factory(:fa_user_with_member_id)
        @organization = Factory(:organization)
      end

      it "should initialize with user and organization" do
        @integration = FA::Integration.new(@user, @organization)
        puts @integration.attributes
        @integration.member_id.should eq @user.member_id
        @integration.partner_id.should eq @organization.id
      end

      it "should create the integration with FA" do
        @integration = FA::Integration.new(@user, @organization)
        FakeWeb.register_uri(:post, "http://staging.api.fracturedatlas.org/members/integrations.xml", :body => @integration.to_xml)
        @integration.save
      end
    end
end