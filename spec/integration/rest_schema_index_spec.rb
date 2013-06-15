require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "create a schema index" do
    it "can create a schema index" do
      si = @neo.create_schema_index("person", ["name"]) 
      si.should_not be_nil
      si["property-keys"].should include("name")
    end
    
  end

  describe "list schema indexes" do
    it "can get a listing of node indexes" do
      si = @neo.get_schema_index("person")
      si.should_not be_nil
      si.first["label"].should include("person")
      si.first["property-keys"].should include("name")
    end
  end
  
  describe "drop schema indexes" do
    it "can drop an existing schema index" do
      si = @neo.delete_schema_index("person", "name")
      si.should be_nil
    end
  end
end