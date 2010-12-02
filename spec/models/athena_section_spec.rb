require 'spec_helper'

describe AthenaChart do
  subject { Factory(:athena_section) }
  
  it { should be_valid }
  
  it { should respond_to :name }
  it { should respond_to :sections }
end