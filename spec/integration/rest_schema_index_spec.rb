require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "create a schema index" do
    it "can create a schema index" do
      si = @neo.create_schema_index("person", ["name"]) 
      expect(si).not_to be_nil
      expect(si["property_keys"]).to include("name")
    end
    
  end

  describe "list schema indexes" do
    it "can get a listing of node indexes" do
      si = @neo.get_schema_index("person")
      expect(si).not_to be_nil
      expect(si.first["label"]).to include("person")
      expect(si.first["property_keys"]).to include("name")
    end
  end
  
  describe "drop schema indexes" do
    it "can drop an existing schema index" do
      si = @neo.delete_schema_index("person", "name")
      expect(si).to be_nil
    end
  end
end