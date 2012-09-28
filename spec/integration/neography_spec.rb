require 'spec_helper'

describe Neography do
  describe "ref_node" do
    it "can get the reference node" do
      root_node = Neography.ref_node
      root_node.should have_key("self")
    end
  end
end
