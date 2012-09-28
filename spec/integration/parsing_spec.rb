require 'spec_helper'

describe Neography do
  subject { Neography::Rest.new }
  describe 'create_node' do
    it 'should not convert strings to symbol' do
      node = subject.create_node({:text => ':1456'})

      node['data']['text'].class.should == String # fails! expected: String got: Symbol (using ==)
      node['data']['text'].should == ':1456'
    end
  end
end
