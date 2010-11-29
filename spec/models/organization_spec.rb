require 'spec_helper'

describe Organization do
  subject { Factory(:organization) }

  it { should respond_to :name }
end
