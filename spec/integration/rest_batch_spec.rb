require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "simple batch" do
    it "can get a single node" do
      new_node = @neo.create_node
      new_node[:id] = new_node["self"].split('/').last
      batch_result = @neo.batch [:get_node, new_node]
      batch_result.first.should_not be_nil
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("body")
      batch_result.first.should have_key("from")
      batch_result.first["body"]["self"].split('/').last.should == new_node[:id]
    end
    
    it "can get multiple nodes" do
      node1 = @neo.create_node
      node1[:id] = node1["self"].split('/').last
      node2 = @neo.create_node
      node2[:id] = node2["self"].split('/').last

      batch_result = @neo.batch [:get_node, node1], [:get_node, node2]
      batch_result.first.should_not be_nil
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("body")
      batch_result.first.should have_key("from")
      batch_result.first["body"]["self"].split('/').last.should == node1[:id]
      batch_result.last.should have_key("id")
      batch_result.last.should have_key("body")
      batch_result.last.should have_key("from")
      batch_result.last["body"]["self"].split('/').last.should == node2[:id]

    end

    it "can create a single node" do
      batch_result = @neo.batch [:create_node, {"name" => "Max"}]
      batch_result.first["body"]["data"]["name"].should == "Max"
    end

    it "can create multiple nodes" do
      batch_result = @neo.batch [:create_node, {"name" => "Max"}], [:create_node, {"name" => "Marc"}]
      batch_result.first["body"]["data"]["name"].should == "Max"
      batch_result.last["body"]["data"]["name"].should == "Marc"
    end

    it "can create multiple nodes given an *array" do
      batch_result = @neo.batch *[[:create_node, {"name" => "Max"}], [:create_node, {"name" => "Marc"}]]
      batch_result.first["body"]["data"]["name"].should == "Max"
      batch_result.last["body"]["data"]["name"].should == "Marc"
    end

    it "can create a unique node" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      @neo.create_node_index(index_name)
      batch_result = @neo.batch [:create_unique_node, index_name, key, value, {"age" => 31, "name" => "Max"}]
      batch_result.first["body"]["data"]["name"].should == "Max"
      batch_result.first["body"]["data"]["age"].should == 31
      new_node_id = batch_result.first["body"]["self"].split('/').last
      batch_result = @neo.batch [:create_unique_node, index_name, key, value, {"age" => 31, "name" => "Max"}]
      batch_result.first["body"]["self"].split('/').last.should == new_node_id
      batch_result.first["body"]["data"]["name"].should == "Max"
      batch_result.first["body"]["data"]["age"].should == 31

      #Sanity Check
      existing_node = @neo.create_unique_node(index_name, key, value, {"age" => 31, "name" => "Max"})
      existing_node["self"].split('/').last.should == new_node_id
      existing_node["data"]["name"].should == "Max"
      existing_node["data"]["age"].should == 31
    end

    it "can update a property of a node" do
      new_node = @neo.create_node("name" => "Max")
      batch_result = @neo.batch [:set_node_property, new_node, {"name" => "Marc"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      existing_node = @neo.get_node(new_node)
      existing_node["data"]["name"].should == "Marc"
    end

    it "can update a property of multiple nodes" do
      node1 = @neo.create_node("name" => "Max")
      node2 = @neo.create_node("name" => "Marc")
      batch_result = @neo.batch [:set_node_property, node1, {"name" => "Tom"}], [:set_node_property, node2, {"name" => "Jerry"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.last.should have_key("id")
      batch_result.last.should have_key("from")
      existing_node = @neo.get_node(node1)
      existing_node["data"]["name"].should == "Tom"
      existing_node = @neo.get_node(node2)
      existing_node["data"]["name"].should == "Jerry"
    end

    it "can reset the properties of a node" do
      new_node = @neo.create_node("name" => "Max", "weight" => 200)
      batch_result = @neo.batch [:reset_node_properties, new_node, {"name" => "Marc"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      existing_node = @neo.get_node(new_node)
      existing_node["data"]["name"].should == "Marc"
      existing_node["data"]["weight"].should be_nil
    end

    it "can reset the properties of multiple nodes" do
      node1 = @neo.create_node("name" => "Max", "weight" => 200)
      node2 = @neo.create_node("name" => "Marc", "weight" => 180)
      batch_result = @neo.batch [:reset_node_properties, node1, {"name" => "Tom"}], [:reset_node_properties, node2, {"name" => "Jerry"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.last.should have_key("id")
      batch_result.last.should have_key("from")
      existing_node = @neo.get_node(node1)
      existing_node["data"]["name"].should == "Tom"
      existing_node["data"]["weight"].should be_nil
      existing_node = @neo.get_node(node2)
      existing_node["data"]["name"].should == "Jerry"
      existing_node["data"]["weight"].should be_nil
    end

    it "can get a single relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", node1, node2)
      batch_result = @neo.batch [:get_relationship, new_relationship]
      batch_result.first["body"]["type"].should == "friends"
      batch_result.first["body"]["start"].split('/').last.should == node1["self"].split('/').last
      batch_result.first["body"]["end"].split('/').last.should == node2["self"].split('/').last
      batch_result.first["body"]["self"].should == new_relationship["self"]
    end
    
    it "can create a single relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_relationship, "friends", node1, node2, {:since => "high school"}]
      batch_result.first["body"]["type"].should == "friends"
      batch_result.first["body"]["data"]["since"].should == "high school"
      batch_result.first["body"]["start"].split('/').last.should == node1["self"].split('/').last
      batch_result.first["body"]["end"].split('/').last.should == node2["self"].split('/').last
    end

    it "can create a unique relationship" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      @neo.create_relationship_index(index_name)
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_unique_relationship, index_name, key, value, "friends", node1, node2]
      batch_result.first["body"]["type"].should == "friends"
      batch_result.first["body"]["start"].split('/').last.should == node1["self"].split('/').last
      batch_result.first["body"]["end"].split('/').last.should == node2["self"].split('/').last
    end

    it "can update a single relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", node1, node2, {:since => "high school"})
      batch_result = @neo.batch [:set_relationship_property, new_relationship, {:since => "college"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      existing_relationship = @neo.get_relationship(new_relationship)
      existing_relationship["type"].should == "friends"
      existing_relationship["data"]["since"].should == "college"
      existing_relationship["start"].split('/').last.should == node1["self"].split('/').last
      existing_relationship["end"].split('/').last.should == node2["self"].split('/').last
      existing_relationship["self"].should == new_relationship["self"]
    end

    it "can reset the properties of a relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", node1, node2, {:since => "high school"})
      batch_result = @neo.batch [:reset_relationship_properties, new_relationship, {"since" => "college", "dated" => "yes"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      existing_relationship = @neo.get_relationship(batch_result.first["from"].split('/')[2])
      existing_relationship["type"].should == "friends"
      existing_relationship["data"]["since"].should == "college"
      existing_relationship["data"]["dated"].should == "yes"
      existing_relationship["start"].split('/').last.should == node1["self"].split('/').last
      existing_relationship["end"].split('/').last.should == node2["self"].split('/').last
      existing_relationship["self"].should == new_relationship["self"]
    end

    it "can add a node to an index" do
      index_name = generate_text(6)
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      new_index = @neo.get_node_index(index_name, key, value) 
      batch_result = @neo.batch [:add_node_to_index, index_name, key, value, new_node]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      existing_index = @neo.find_node_index(index_name, key, value) 
      existing_index.should_not be_nil
      existing_index.first["self"].should == new_node["self"]
      @neo.remove_node_from_index(index_name, key, value, new_node) 
    end

    it "can get a node index" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      @neo.create_node_index(index_name)
      new_node = @neo.create_node
      @neo.add_node_to_index(index_name, key, value, new_node)
      batch_result = @neo.batch [:get_node_index, index_name, key, value]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.first["body"].first["self"].should == new_node["self"]
      @neo.remove_node_from_index(index_name, key, value, new_node) 
    end

    it "can get a relationship index" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      @neo.create_relationship_index(index_name)
      node1 = @neo.create_node
      node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", node1, node2, {:since => "high school"})
      @neo.add_relationship_to_index(index_name, key, value, new_relationship)
      batch_result = @neo.batch [:get_relationship_index, index_name, key, value]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.first["body"].first["type"].should == "friends"
      batch_result.first["body"].first["start"].split('/').last.should == node1["self"].split('/').last
      batch_result.first["body"].first["end"].split('/').last.should == node2["self"].split('/').last
    end

    it "can batch gremlin" do
      batch_result = @neo.batch [:execute_script, "g.v(0)"]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.first["body"]["self"].split('/').last.should == "0"
    end  

    it "can batch gremlin with parameters" do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      batch_result = @neo.batch [:execute_script, "g.v(id)", {:id => id.to_i}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.first["body"]["self"].split('/').last.should == id
    end  

    it "can batch cypher" do
      batch_result = @neo.batch [:execute_query, "start n=node(0) return n"]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.first["body"]["data"][0][0]["self"].split('/').last.should == "0"
    end  

    it "can batch cypher with parameters" do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      batch_result = @neo.batch [:execute_query, "start n=node({id}) return n", {:id => id.to_i}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.first["body"]["data"][0][0]["self"].split('/').last.should == id
    end  
  
	it "can delete a node in batch" do
		
		node1 = @neo.create_node
		node2 = @neo.create_node
		id1 = node1['self'].split('/').last
		id2 = node2['self'].split('/').last
		batch_result = @neo.batch [:delete_node, id1 ], [:delete_node, id2]
		@neo.get_node(node1).should be_nil
		@neo.get_node(node2).should be_nil

	end

	it "can remove a node from an index in batch " do
		index = generate_text(6)
		key = generate_text(6)
		value1 = generate_text
		value2 = generate_text 
		
		node1 = @neo.create_unique_node( index , key  , value1  , { "name" => "Max" } )
		node2 = @neo.create_unique_node( index , key , value2 , { "name" => "Neo" }) 
		
		batch_result = @neo.batch [:remove_node_from_index, index, key, value1, node1 ], [:remove_node_from_index, index, key, value2, node2 ]
		
		@neo.get_node_index(index, key, value1).should be_nil
		@neo.get_node_index(index, key, value2).should be_nil
	end

  end

  describe "referenced batch" do
    it "can create a relationship from two newly created nodes" do
      batch_result = @neo.batch [:create_node, {"name" => "Max"}], [:create_node, {"name" => "Marc"}], [:create_relationship, "friends", "{0}", "{1}", {:since => "high school"}]
      batch_result.first["body"]["data"]["name"].should == "Max"
      batch_result[1]["body"]["data"]["name"].should == "Marc"
      batch_result.last["body"]["type"].should == "friends"
      batch_result.last["body"]["data"]["since"].should == "high school"
      batch_result.last["body"]["start"].split('/').last.should == batch_result.first["body"]["self"].split('/').last
      batch_result.last["body"]["end"].split('/').last.should == batch_result[1]["body"]["self"].split('/').last
    end

    it "can create a relationship from an existing node and a newly created node" do
      node1 = @neo.create_node("name" => "Max", "weight" => 200)
      batch_result = @neo.batch [:create_node, {"name" => "Marc"}], [:create_relationship, "friends", "{0}", node1, {:since => "high school"}]
      batch_result.first["body"]["data"]["name"].should == "Marc"
      batch_result.last["body"]["type"].should == "friends"
      batch_result.last["body"]["data"]["since"].should == "high school"
      batch_result.last["body"]["start"].split('/').last.should == batch_result.first["body"]["self"].split('/').last
      batch_result.last["body"]["end"].split('/').last.should == node1["self"].split('/').last
    end

    it "can add a newly created node to an index" do
      key = generate_text(6)
      value = generate_text
      new_index = @neo.get_node_index("test_node_index", key, value) 
      batch_result = @neo.batch [:create_node, {"name" => "Max"}], [:add_node_to_index, "test_node_index", key, value, "{0}"]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      existing_index = @neo.find_node_index("test_node_index", key, value) 
      existing_index.should_not be_nil
      existing_index.first["self"].should == batch_result.first["body"]["self"]
      @neo.remove_node_from_index("test_node_index", key, value, batch_result.first["body"]["self"].split('/').last) 
    end

    it "can add a newly created relationship to an index" do
      key = generate_text(6)
      value = generate_text
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_relationship, "friends", node1, node2, {:since => "high school"}], [:add_relationship_to_index, "test_relationship_index", key, value, "{0}"]
      batch_result.first["body"]["type"].should == "friends"
      batch_result.first["body"]["data"]["since"].should == "high school"
      batch_result.first["body"]["start"].split('/').last.should == node1["self"].split('/').last
      batch_result.first["body"]["end"].split('/').last.should == node2["self"].split('/').last
      existing_index = @neo.find_relationship_index("test_relationship_index", key, value) 
      existing_index.should_not be_nil
      existing_index.first["self"].should == batch_result.first["body"]["self"]
    end

    it "can reset the properties of a newly created relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_relationship, "friends", node1, node2, {:since => "high school"}], [:reset_relationship_properties, "{0}", {"since" => "college", "dated" => "yes"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      existing_relationship = @neo.get_relationship(batch_result.first["body"]["self"].split('/').last)
      existing_relationship["type"].should == "friends"
      existing_relationship["data"]["since"].should == "college"
      existing_relationship["data"]["dated"].should == "yes"
      existing_relationship["start"].split('/').last.should == node1["self"].split('/').last
      existing_relationship["end"].split('/').last.should == node2["self"].split('/').last
      existing_relationship["self"].should == batch_result.first["body"]["self"]
    end

    it "can kitchen sink" do
      key = generate_text(6)
      value = generate_text

      batch_result = @neo.batch [:create_node, {"name" => "Max"}], 
                                [:create_node, {"name" => "Marc"}],                           
                                [:add_node_to_index, "test_node_index", key, value, "{0}"]
                                [:add_node_to_index, "test_node_index", key, value, "{1}"]
                                [:create_relationship, "friends", "{0}", "{1}", {:since => "college"}]                        
                                [:add_relationship_to_index, "test_relationship_index", key, value, "{4}"] 
      batch_result.should_not be_nil
    end

    it "can get multiple relationships" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      node3 = @neo.create_node
      new_relationship1 = @neo.create_relationship("friends", node1, node2)
      new_relationship2 = @neo.create_relationship("brothers", node1, node3)
      batch_result = @neo.batch [:get_node_relationships, node1]
      batch_result.first["body"][0]["type"].should == "friends"
      batch_result.first["body"][0]["start"].split('/').last.should == node1["self"].split('/').last
      batch_result.first["body"][0]["end"].split('/').last.should == node2["self"].split('/').last
      batch_result.first["body"][0]["self"].should == new_relationship1["self"]
      batch_result.first["body"][1]["type"].should == "brothers"
      batch_result.first["body"][1]["start"].split('/').last.should == node1["self"].split('/').last
      batch_result.first["body"][1]["end"].split('/').last.should == node3["self"].split('/').last
      batch_result.first["body"][1]["self"].should == new_relationship2["self"]
    end

    it "can create a relationship from a unique node" do

      require 'net-http-spy'
      Net::HTTP.http_logger_options = {:verbose => true} # see everything

      batch_result = @neo.batch [:create_node, {:street1=>"94437 Kemmer Crossing", :street2=>"Apt. 333", :city=>"Abshireton", :state=>"AA", :zip=>"65820", :_type=>"Address", :created_at=>1335269478}],
                                [:add_node_to_index, "person_ssn", "ssn", "000-00-0001", "{0}"],
                                [:create_unique_node, "person", "ssn", "000-00-0001", {:first_name=>"Jane", :last_name=>"Doe", :ssn=>"000-00-0001", :_type=>"Person", :created_at=>1335269478}],
                                [:create_relationship, "has", "{0}", "{2}", {}]   
      puts batch_result.inspect


      batch_result = @neo.batch [:create_unique_node, "person", "ssn", "000-00-0001", {:first_name=>"Jane", :last_name=>"Doe", :ssn=>"000-00-0001", :_type=>"Person", :created_at=>1335269478}],
                                [:add_node_to_index, "person_ssn", "ssn", "000-00-0001", "{0}"],
                                [:create_node, {:street1=>"94437 Kemmer Crossing", :street2=>"Apt. 333", :city=>"Abshireton", :state=>"AA", :zip=>"65820", :_type=>"Address", :created_at=>1335269478}],
                                [:create_relationship, "has", "{0}", "{2}", {}]
    
     puts batch_result.inspect
    end

  end
  
end
