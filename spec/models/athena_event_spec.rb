require 'spec_helper'

describe AthenaEvent do
  subject { Factory(:athena_event) }
  
  it { should be_valid }
  
  it { should respond_to :name }
  it { should respond_to :venue }
  it { should respond_to :producer }
  it { should respond_to :chart_id }
  it { should respond_to :chart }
end