require 'spec_helper'

describe Neography::Rest, :slow => true do
  describe "basic authentication"  do
    describe "get_root", :reference => true do
      it "can get the root node"do
        @neo = Neography::Rest.new({:authentication => 'digest', :username => "username", :password => "password"})
        root_node = @neo.get_root
        expect(root_node).to have_key("reference_node")
      end
    end    
    
    describe "create_node" do
      it "can create an empty node" do
        @neo = Neography::Rest.new({:authentication => 'basic', :username => "username", :password => "password"})
        new_node = @neo.create_node
        expect(new_node).not_to be_nil
      end
    end

    describe "quick initializer" do
      it "can create an empty node" do
        @neo = Neography::Rest.new("http://username:password@localhost:7474")
        new_node = @neo.create_node
        expect(new_node).not_to be_nil
      end
    end
  end

  describe "digest authentication"  do
    describe "create_node" do
      it "can create an empty node" do
        @neo = Neography::Rest.new({:authentication => 'digest', :username => "username", :password => "password"})
        new_node = @neo.create_node
        expect(new_node).not_to be_nil
      end
    end
  end

end
