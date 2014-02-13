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
      uc.should_not be_nil
      uc["label"].should == label
      uc["property_keys"].should == [property]
    end
  end

  describe "get a unique constraint" do
    it "can get a unique constraint" do
      label = "User"
      property = "user_id"
      uc = @neo.get_unique_constraint(label, property)
      uc.should_not be_nil
      uc.first["label"].should == label
      uc.first["property_keys"].should == [property]
    end
  end

  describe "get unique constraints" do
    it "can get unique constraints for a label" do
      label = "User"
      property = "user_id"
      uc = @neo.get_uniqueness(label)
      uc.should_not be_nil
      uc.first["label"].should == label
      uc.first["property_keys"].should == [property]
    end
  end
  
  describe "list constraints" do
    it "can get a list of constraints" do
      label = "User"
      property = "user_id"
      cs = @neo.get_constraints
      cs.should_not be_nil
      cs.first["label"].should == label
      cs.first["property_keys"].should == [property]
    end

    it "can get a list of constraints for a specifc label" do
      label = "User"
      property = "user_id"
      cs = @neo.get_constraints(label)
      cs.should_not be_nil
      cs.first["label"].should == label
      cs.first["property_keys"].should == [property]
    end
  end
  
  describe "drop a constraint" do
    it "can drop a constraint" do
      label = "User"
      property = "user_id"
      uc = @neo.drop_constraint(label, property)
      uc.should be_nil
      cs = @neo.get_constraints(label)
      cs.should be_empty
    end
  end
    
end