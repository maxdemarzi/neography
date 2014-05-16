require 'spec_helper'

describe Neography do
  subject { Neography::Rest.new }
  describe 'create_node' do
    it 'should not convert strings to symbol' do
      node = subject.create_node({:text => ':1456'})

      expect(node['data']['text'].class).to eq(String) # fails! expected: String got: Symbol (using ==)
      expect(node['data']['text']).to eq(':1456')
    end
  end
end
