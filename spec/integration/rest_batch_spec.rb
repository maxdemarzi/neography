require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "simple batch" do
    it "can get a single node" do
      pending
    end
    
    it "can get multiple nodes" do
      pending
    end

    it "can create a single node" do
      pending
    end

    it "can create multiple nodes" do
      pending
    end

    it "can update a single node" do
      pending
    end

    it "can update multiple nodes" do
      pending
    end

    it "can get a single relationship" do
      pending
    end
    
    it "can get multiple relationships" do
      pending
    end

    it "can create a single relationship" do
      pending
    end

    it "can create multiple relationships" do
      pending
    end

    it "can update a single relationship" do
      pending
    end

    it "can update multiple relationships" do
      pending
    end

    it "can add a node to an index" do
      pending
    end
  end

  describe "referenced batch" do
    it "can create a relationship from two newly created nodes" do
      pending
    end

    it "can create a relationship from an existing node and a newly created node" do
      pending
    end

    it "can add a newly created node to an index" do
      pending
    end

    it "can add a newly created relationship to an index" do
      pending
    end
  end
  
end