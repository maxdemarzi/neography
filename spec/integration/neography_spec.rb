require 'spec_helper'

describe Neography do
  describe "ref_node", :reference => true do
    it "can get the reference node" do
      root_node = Neography.ref_node
      expect(root_node).to have_key("self")
    end
  end
end
