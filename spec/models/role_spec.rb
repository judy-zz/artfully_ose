require 'spec_helper'

describe Role do
  subject { Factory(:role) }
  it { should respond_to :users }
end
