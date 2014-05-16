require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "create unique constraint" do
    it "can create a unique constraint" do
      label = "User"
      property = "user_id"
      uc = @neo.create_unique_constraint(label, property)
      expect(uc).not_to be_nil
      expect(uc["label"]).to eq(label)
      expect(uc["property_keys"]).to eq([property])
    end
  end

  describe "get a unique constraint" do
    it "can get a unique constraint" do
      label = "User"
      property = "user_id"
      uc = @neo.get_unique_constraint(label, property)
      expect(uc).not_to be_nil
      expect(uc.first["label"]).to eq(label)
      expect(uc.first["property_keys"]).to eq([property])
    end
  end

  describe "get unique constraints" do
    it "can get unique constraints for a label" do
      label = "User"
      property = "user_id"
      uc = @neo.get_uniqueness(label)
      expect(uc).not_to be_nil
      expect(uc.first["label"]).to eq(label)
      expect(uc.first["property_keys"]).to eq([property])
    end
  end
  
  describe "list constraints" do
    it "can get a list of constraints" do
      label = "User"
      property = "user_id"
      cs = @neo.get_constraints
      expect(cs).not_to be_nil
      expect(cs.first["label"]).to eq(label)
      expect(cs.first["property_keys"]).to eq([property])
    end

    it "can get a list of constraints for a specifc label" do
      label = "User"
      property = "user_id"
      cs = @neo.get_constraints(label)
      expect(cs).not_to be_nil
      expect(cs.first["label"]).to eq(label)
      expect(cs.first["property_keys"]).to eq([property])
    end
  end
  
  describe "drop a constraint" do
    it "can drop a constraint" do
      label = "User"
      property = "user_id"
      uc = @neo.drop_constraint(label, property)
      expect(uc).to be_nil
      cs = @neo.get_constraints(label)
      expect(cs).to be_empty
    end
  end
    
end