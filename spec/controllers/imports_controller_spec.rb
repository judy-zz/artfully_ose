require 'spec_helper'

describe ImportsController do

  context "GET new" do
    before do
      get :new
    end

    should { respond_with :success }
  end

end
