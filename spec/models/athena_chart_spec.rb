require 'spec_helper'

describe AthenaChart do
  subject { Factory(:athena_chart) }
  
  it { should be_valid }
  
  it { should respond_to :name }
end