require 'spec_helper'

describe AthenaPerformance do
  subject { Factory(:athena_performance) }
  
  it { should be_valid }
  
  it { should respond_to :event_id }
  it { should respond_to :event }
  it { should respond_to :chart_id }
  it { should respond_to :chart }
end