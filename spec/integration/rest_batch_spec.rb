require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "simple batch" do
    it "can get a single node" do
      new_node = @neo.create_node
      new_node[:id] = new_node["self"].split('/').last
      batch_result = @neo.batch [:get_node, new_node]
      expect(batch_result.first).not_to be_nil
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("body")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.first["body"]["self"].split('/').last).to eq(new_node[:id])
    end

    it "can get multiple nodes" do
      node1 = @neo.create_node
      node1[:id] = node1["self"].split('/').last
      node2 = @neo.create_node
      node2[:id] = node2["self"].split('/').last

      batch_result = @neo.batch [:get_node, node1], [:get_node, node2]
      expect(batch_result.first).not_to be_nil
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("body")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.first["body"]["self"].split('/').last).to eq(node1[:id])
      expect(batch_result.last).to have_key("id")
      expect(batch_result.last).to have_key("body")
      expect(batch_result.last).to have_key("from")
      expect(batch_result.last["body"]["self"].split('/').last).to eq(node2[:id])

    end

    it "can create a single node" do
      batch_result = @neo.batch [:create_node, {"name" => "Max"}]
      expect(batch_result.first["body"]["data"]["name"]).to eq("Max")
    end

    it "can create multiple nodes" do
      batch_result = @neo.batch [:create_node, {"name" => "Max"}], [:create_node, {"name" => "Marc"}]
      expect(batch_result.first["body"]["data"]["name"]).to eq("Max")
      expect(batch_result.last["body"]["data"]["name"]).to eq("Marc")
    end

    it "can create multiple nodes given an *array" do
      batch_result = @neo.batch *[[:create_node, {"name" => "Max"}], [:create_node, {"name" => "Marc"}]]
      expect(batch_result.first["body"]["data"]["name"]).to eq("Max")
      expect(batch_result.last["body"]["data"]["name"]).to eq("Marc")
    end

    it "can create a unique node" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      @neo.create_node_index(index_name)
      batch_result = @neo.batch [:create_unique_node, index_name, key, value, {"age" => 31, "name" => "Max"}]
      expect(batch_result.first["body"]["data"]["name"]).to eq("Max")
      expect(batch_result.first["body"]["data"]["age"]).to eq(31)
      new_node_id = batch_result.first["body"]["self"].split('/').last
      batch_result = @neo.batch [:create_unique_node, index_name, key, value, {"age" => 31, "name" => "Max"}]
      expect(batch_result.first["body"]["self"].split('/').last).to eq(new_node_id)
      expect(batch_result.first["body"]["data"]["name"]).to eq("Max")
      expect(batch_result.first["body"]["data"]["age"]).to eq(31)

      #Sanity Check
      existing_node = @neo.create_unique_node(index_name, key, value, {"age" => 31, "name" => "Max"})
      expect(existing_node["self"].split('/').last).to eq(new_node_id)
      expect(existing_node["data"]["name"]).to eq("Max")
      expect(existing_node["data"]["age"]).to eq(31)
    end

    it "can create or fail a unique node" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      @neo.create_node_index(index_name)
      batch_result = @neo.batch [:create_or_fail_unique_node, index_name, key, value, {"age" => 31, "name" => "Max"}]
      expect(batch_result.first["body"]["data"]["name"]).to eq("Max")
      expect(batch_result.first["body"]["data"]["age"]).to eq(31)
      new_node_id = batch_result.first["body"]["self"].split('/').last
      expect {
        batch_result = @neo.batch [:create_or_fail_unique_node, index_name, key, value, {"age" => 31, "name" => "Max"}]
      }.to raise_error Neography::OperationFailureException

    end
    it "can update a property of a node" do
      new_node = @neo.create_node("name" => "Max")
      batch_result = @neo.batch [:set_node_property, new_node, {"name" => "Marc"}]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      existing_node = @neo.get_node(new_node)
      expect(existing_node["data"]["name"]).to eq("Marc")
    end

    it "can update a property of multiple nodes" do
      node1 = @neo.create_node("name" => "Max")
      node2 = @neo.create_node("name" => "Marc")
      batch_result = @neo.batch [:set_node_property, node1, {"name" => "Tom"}], [:set_node_property, node2, {"name" => "Jerry"}]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.last).to have_key("id")
      expect(batch_result.last).to have_key("from")
      existing_node = @neo.get_node(node1)
      expect(existing_node["data"]["name"]).to eq("Tom")
      existing_node = @neo.get_node(node2)
      expect(existing_node["data"]["name"]).to eq("Jerry")
    end

    it "can reset the properties of a node" do
      new_node = @neo.create_node("name" => "Max", "weight" => 200)
      batch_result = @neo.batch [:reset_node_properties, new_node, {"name" => "Marc"}]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      existing_node = @neo.get_node(new_node)
      expect(existing_node["data"]["name"]).to eq("Marc")
      expect(existing_node["data"]["weight"]).to be_nil
    end

    it "can reset the properties of multiple nodes" do
      node1 = @neo.create_node("name" => "Max", "weight" => 200)
      node2 = @neo.create_node("name" => "Marc", "weight" => 180)
      batch_result = @neo.batch [:reset_node_properties, node1, {"name" => "Tom"}], [:reset_node_properties, node2, {"name" => "Jerry"}]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.last).to have_key("id")
      expect(batch_result.last).to have_key("from")
      existing_node = @neo.get_node(node1)
      expect(existing_node["data"]["name"]).to eq("Tom")
      expect(existing_node["data"]["weight"]).to be_nil
      existing_node = @neo.get_node(node2)
      expect(existing_node["data"]["name"]).to eq("Jerry")
      expect(existing_node["data"]["weight"]).to be_nil
    end

    it "can remove a property of a node" do
      new_node = @neo.create_node("name" => "Max", "weight" => 200)
      batch_result = @neo.batch [:remove_node_property, new_node, "weight"]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      existing_node = @neo.get_node(new_node)
      expect(existing_node["data"]["name"]).to eq("Max")
      expect(existing_node["data"]["weight"]).to be_nil
    end

    it "can remove a property of multiple nodes" do
      node1 = @neo.create_node("name" => "Max", "weight" => 200)
      node2 = @neo.create_node("name" => "Marc", "weight" => 180)
      batch_result = @neo.batch [:remove_node_property, node1, "name"], [:remove_node_property, node2, "name"]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.last).to have_key("id")
      expect(batch_result.last).to have_key("from")
      existing_node = @neo.get_node(node1)
      expect(existing_node["data"]["name"]).to be_nil
      expect(existing_node["data"]["weight"]).to eq(200)
      existing_node = @neo.get_node(node2)
      expect(existing_node["data"]["name"]).to be_nil
      expect(existing_node["data"]["weight"]).to eq(180)
    end

    it "can get a single relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", node1, node2)
      batch_result = @neo.batch [:get_relationship, new_relationship]
      expect(batch_result.first["body"]["type"]).to eq("friends")
      expect(batch_result.first["body"]["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(batch_result.first["body"]["end"].split('/').last).to eq(node2["self"].split('/').last)
      expect(batch_result.first["body"]["self"]).to eq(new_relationship["self"])
    end

    it "can create a single relationship without properties" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_relationship, "friends", node1, node2]
      expect(batch_result.first["body"]["type"]).to eq("friends")
      expect(batch_result.first["body"]["data"]["since"]).to be_nil
      expect(batch_result.first["body"]["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(batch_result.first["body"]["end"].split('/').last).to eq(node2["self"].split('/').last)
    end

    it "can create a single relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_relationship, "friends", node1, node2, {:since => "high school"}]
      expect(batch_result.first["body"]["type"]).to eq("friends")
      expect(batch_result.first["body"]["data"]["since"]).to eq("high school")
      expect(batch_result.first["body"]["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(batch_result.first["body"]["end"].split('/').last).to eq(node2["self"].split('/').last)
    end

    it "can delete a single relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_relationship, "friends", node1, node2, {:since => "time immemorial"}]
      expect(batch_result).not_to be_nil
      expect(batch_result[0]["status"]).to eq(201)
      id = batch_result.first["body"]["self"].split("/").last
      batch_result = @neo.batch [:delete_relationship, id]
      expect(batch_result[0]["status"]).to eq(204)
      expect(batch_result[0]["from"]).to eq("/relationship/#{id}")
    end

    it "can create a unique relationship" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      @neo.create_relationship_index(index_name)
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_unique_relationship, index_name, key, value, "friends", node1, node2]
      expect(batch_result.first["body"]["type"]).to eq("friends")
      expect(batch_result.first["body"]["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(batch_result.first["body"]["end"].split('/').last).to eq(node2["self"].split('/').last)
    end

    it "can update a single relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", node1, node2, {:since => "high school"})
      batch_result = @neo.batch [:set_relationship_property, new_relationship, {:since => "college"}]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      existing_relationship = @neo.get_relationship(new_relationship)
      expect(existing_relationship["type"]).to eq("friends")
      expect(existing_relationship["data"]["since"]).to eq("college")
      expect(existing_relationship["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(existing_relationship["end"].split('/').last).to eq(node2["self"].split('/').last)
      expect(existing_relationship["self"]).to eq(new_relationship["self"])
    end

    it "can reset the properties of a relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", node1, node2, {:since => "high school"})
      batch_result = @neo.batch [:reset_relationship_properties, new_relationship, {"since" => "college", "dated" => "yes"}]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      existing_relationship = @neo.get_relationship(batch_result.first["from"].split('/')[2])
      expect(existing_relationship["type"]).to eq("friends")
      expect(existing_relationship["data"]["since"]).to eq("college")
      expect(existing_relationship["data"]["dated"]).to eq("yes")
      expect(existing_relationship["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(existing_relationship["end"].split('/').last).to eq(node2["self"].split('/').last)
      expect(existing_relationship["self"]).to eq(new_relationship["self"])
    end

    it "can drop a node index" do
      index_name = generate_text(6)
      @neo.create_node_index(index_name)
      @neo.batch [:drop_node_index, index_name]
      expect(@neo.list_node_indexes[index_name]).to be_nil
    end

    it "can create a node index" do
      index_name = generate_text(6)
      @neo.batch [:create_node_index, index_name, "fulltext", "lucene"]
      indexes = @neo.list_node_indexes
      index = indexes[index_name]
      expect(index).not_to be_nil
      expect(index["provider"]).to eq("lucene")
      expect(index["type"]).to eq("fulltext")
    end

    it "can add a node to an index" do
      index_name = generate_text(6)
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      batch_result = @neo.batch [:add_node_to_index, index_name, key, value, new_node]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      existing_index = @neo.find_node_index(index_name, key, value)
      expect(existing_index).not_to be_nil
      expect(existing_index.first["self"]).to eq(new_node["self"])
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
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.first["body"].first["self"]).to eq(new_node["self"])
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
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.first["body"].first["type"]).to eq("friends")
      expect(batch_result.first["body"].first["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(batch_result.first["body"].first["end"].split('/').last).to eq(node2["self"].split('/').last)
    end

    it "can batch gremlin", :gremlin => true  do
      batch_result = @neo.batch [:execute_script, "g.v(0)"]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.first["body"]["self"].split('/').last).to eq("0")
    end

    it "can batch gremlin with parameters", :gremlin => true  do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      batch_result = @neo.batch [:execute_script, "g.v(id)", {:id => id.to_i}]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.first["body"]["self"].split('/').last).to eq(id)
    end

    it "can batch cypher" do
      batch_result = @neo.batch [:execute_query, "start n=node(0) return n"]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.first["body"]["data"][0][0]["self"].split('/').last).to eq("0")
    end

    it "can batch cypher with parameters" do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      batch_result = @neo.batch [:execute_query, "start n=node({id}) return n", {:id => id.to_i}]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      expect(batch_result.first["body"]["data"][0][0]["self"].split('/').last).to eq(id)
    end

    it "raises ParameterNotFoundException when a cypher parameter is missing and ORDER BY is used" do
      q = "MATCH n WHERE n.x>{missing_parameter} RETURN n ORDER BY n"
      expect{
        @neo.batch [:execute_query, q, {}]
      }.to raise_error Neography::ParameterNotFoundException
    end

  	it "can delete a node in batch" do
  		node1 = @neo.create_node
  		node2 = @neo.create_node
  		id1 = node1['self'].split('/').last
  		id2 = node2['self'].split('/').last
  		batch_result = @neo.batch [:delete_node, id1 ], [:delete_node, id2]
      expect {
        expect(@neo.get_node(node1)).to be_nil
      }.to raise_error Neography::NodeNotFoundException
      expect {
        expect(@neo.get_node(node2)).to be_nil
      }.to raise_error Neography::NodeNotFoundException
  	end

  	it "can remove a node from an index in batch " do
  		index = generate_text(6)
  		key = generate_text(6)
  		value1 = generate_text
  		value2 = generate_text
  		value3 = generate_text

  		node1 = @neo.create_unique_node(index, key, value1, { "name" => "Max" })
  		node2 = @neo.create_unique_node(index, key, value2, { "name" => "Neo" })
  		node3 = @neo.create_unique_node(index, key, value3, { "name" => "Samir"})

  		batch_result = @neo.batch [:remove_node_from_index, index, key, value1, node1 ],
  		                          [:remove_node_from_index, index, key, node2 ],
  		                          [:remove_node_from_index, index, node3 ]

  		expect(@neo.get_node_index(index, key, value1)).to be_nil
  		expect(@neo.get_node_index(index, key, value2)).to be_nil
  		expect(@neo.get_node_index(index, key, value3)).to be_nil
  	end

    it "can remove a relationship from an index in batch" do
       index = generate_text(6)
       key = generate_text(6)
       value1 = generate_text
       value2 = generate_text

       node1 = @neo.create_node
       node2 = @neo.create_node
       relationship1 = @neo.create_unique_relationship(index, key, value1, "friends", node1, node2)
       relationship2 = @neo.create_unique_relationship(index, key, value2, "friends", node2, node1)

       batch_result = @neo.batch [:remove_relationship_from_index, index, key, relationship1],
         [:remove_relationship_from_index, index, key, relationship2]

       expect(@neo.get_relationship_index(index, key, value1)).to be_nil
       expect(@neo.get_relationship_index(index, key, value2)).to be_nil
     end
    
    it "can do spatial via Cypher in batch" do
      properties = {:lat => 60.1, :lon => 15.2}
      node = @neo.create_node(properties)
      batch_result = @neo.batch [:create_spatial_index, "geobatchcypher", "point", "lat", "lon"],
                                [:add_node_to_spatial_index, "geobatchcypher", node],
                                [:execute_query, "start n = node:geobatchcypher({withinDistance}) return n", {:withinDistance => "withinDistance:[60.0,15.0,100.0]"}],
                                [:execute_query, "start n = node:geobatchcypher({bbox}) return n", {:bbox => "bbox:[15.0,15.3,60.0,60.2]"}]

      expect(batch_result[0]["body"]["provider"]).to eq("spatial")
      expect(batch_result[0]["body"]["geometry_type"]).to eq("point")
      expect(batch_result[0]["body"]["lat"]).to eq("lat")
      expect(batch_result[0]["body"]["lon"]).to eq("lon")
      expect(batch_result[1]["from"]).to eq("/index/node/geobatchcypher")
      expect(batch_result[1]["body"]["data"]).to eq({"lat" => 60.1, "lon" => 15.2})
      expect(batch_result[2]["body"]["data"]).not_to be_empty
      expect(batch_result[3]["body"]["data"]).not_to be_empty
    end
  end

  describe "referenced batch" do
    it "can create a relationship from two newly created nodes" do
      batch_result = @neo.batch [:create_node, {"name" => "Max"}], [:create_node, {"name" => "Marc"}], [:create_relationship, "friends", "{0}", "{1}", {:since => "high school"}]
      expect(batch_result.first["body"]["data"]["name"]).to eq("Max")
      expect(batch_result[1]["body"]["data"]["name"]).to eq("Marc")
      expect(batch_result.last["body"]["type"]).to eq("friends")
      expect(batch_result.last["body"]["data"]["since"]).to eq("high school")
      expect(batch_result.last["body"]["start"].split('/').last).to eq(batch_result.first["body"]["self"].split('/').last)
      expect(batch_result.last["body"]["end"].split('/').last).to eq(batch_result[1]["body"]["self"].split('/').last)
    end

    it "can create a relationship from an existing node and a newly created node" do
      node1 = @neo.create_node("name" => "Max", "weight" => 200)
      batch_result = @neo.batch [:create_node, {"name" => "Marc"}], [:create_relationship, "friends", "{0}", node1, {:since => "high school"}]
      expect(batch_result.first["body"]["data"]["name"]).to eq("Marc")
      expect(batch_result.last["body"]["type"]).to eq("friends")
      expect(batch_result.last["body"]["data"]["since"]).to eq("high school")
      expect(batch_result.last["body"]["start"].split('/').last).to eq(batch_result.first["body"]["self"].split('/').last)
      expect(batch_result.last["body"]["end"].split('/').last).to eq(node1["self"].split('/').last)
    end

    it "can add a newly created node to an index" do
      key = generate_text(6)
      value = generate_text
      batch_result = @neo.batch [:create_node, {"name" => "Max"}], [:add_node_to_index, "test_node_index", key, value, "{0}"]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      existing_index = @neo.find_node_index("test_node_index", key, value)
      expect(existing_index).not_to be_nil
      expect(existing_index.first["self"]).to eq(batch_result.first["body"]["self"])
      @neo.remove_node_from_index("test_node_index", key, value, batch_result.first["body"]["self"].split('/').last)
    end

    it "can add a newly created relationship to an index" do
      key = generate_text(6)
      value = generate_text
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_relationship, "friends", node1, node2, {:since => "high school"}], [:add_relationship_to_index, "test_relationship_index", key, value, "{0}"]
      expect(batch_result.first["body"]["type"]).to eq("friends")
      expect(batch_result.first["body"]["data"]["since"]).to eq("high school")
      expect(batch_result.first["body"]["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(batch_result.first["body"]["end"].split('/').last).to eq(node2["self"].split('/').last)
      existing_index = @neo.find_relationship_index("test_relationship_index", key, value)
      expect(existing_index).not_to be_nil
      expect(existing_index.first["self"]).to eq(batch_result.first["body"]["self"])
    end

    it "can reset the properties of a newly created relationship" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      batch_result = @neo.batch [:create_relationship, "friends", node1, node2, {:since => "high school"}], [:reset_relationship_properties, "{0}", {"since" => "college", "dated" => "yes"}]
      expect(batch_result.first).to have_key("id")
      expect(batch_result.first).to have_key("from")
      existing_relationship = @neo.get_relationship(batch_result.first["body"]["self"].split('/').last)
      expect(existing_relationship["type"]).to eq("friends")
      expect(existing_relationship["data"]["since"]).to eq("college")
      expect(existing_relationship["data"]["dated"]).to eq("yes")
      expect(existing_relationship["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(existing_relationship["end"].split('/').last).to eq(node2["self"].split('/').last)
      expect(existing_relationship["self"]).to eq(batch_result.first["body"]["self"])
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
      expect(batch_result).not_to be_nil
    end

    it "can get multiple relationships" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      node3 = @neo.create_node
      new_relationship1 = @neo.create_relationship("friends", node1, node2)
      new_relationship2 = @neo.create_relationship("brothers", node1, node3)
      batch_result = @neo.batch [:get_node_relationships, node1]
      expect(batch_result.first["body"].length).to be(2)
      expect(batch_result.first["body"][0]["type"]).to eq("friends")
      expect(batch_result.first["body"][0]["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(batch_result.first["body"][0]["end"].split('/').last).to eq(node2["self"].split('/').last)
      expect(batch_result.first["body"][0]["self"]).to eq(new_relationship1["self"])
      expect(batch_result.first["body"][1]["type"]).to eq("brothers")
      expect(batch_result.first["body"][1]["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(batch_result.first["body"][1]["end"].split('/').last).to eq(node3["self"].split('/').last)
      expect(batch_result.first["body"][1]["self"]).to eq(new_relationship2["self"])
    end

    it "can get relationships of specific type" do
      node1 = @neo.create_node
      node2 = @neo.create_node
      node3 = @neo.create_node
      new_relationship1 = @neo.create_relationship("friends", node1, node2)
      new_relationship2 = @neo.create_relationship("brothers", node1, node3)
      batch_result = @neo.batch [:get_node_relationships, node1, "out", "friends"]
      expect(batch_result.first["body"].length).to be(1)
      expect(batch_result.first["body"][0]["type"]).to eq("friends")
      expect(batch_result.first["body"][0]["start"].split('/').last).to eq(node1["self"].split('/').last)
      expect(batch_result.first["body"][0]["end"].split('/').last).to eq(node2["self"].split('/').last)
      expect(batch_result.first["body"][0]["self"]).to eq(new_relationship1["self"])
    end

    it "can create a relationship from a unique node" do
      batch_result = @neo.batch [:create_node, {:street1=>"94437 Kemmer Crossing", :street2=>"Apt. 333", :city=>"Abshireton", :state=>"AA", :zip=>"65820", :_type=>"Address", :created_at=>1335269478}],
                                [:add_node_to_index, "person_ssn", "ssn", "000-00-0001", "{0}"],
                                [:create_unique_node, "person", "ssn", "000-00-0001", {:first_name=>"Jane", :last_name=>"Doe", :ssn=>"000-00-0001", :_type=>"Person", :created_at=>1335269478}],
                                [:create_relationship, "has", "{0}", "{2}", {}]
      expect(batch_result).not_to be_nil

      # create_unique_node is returning an index result, not a node, so we can't do this yet.
      # See https://github.com/neo4j/community/issues/697

      expect {
              batch_result = @neo.batch [:create_unique_node, "person", "ssn", "000-00-0001", {:first_name=>"Jane", :last_name=>"Doe", :ssn=>"000-00-0001", :_type=>"Person", :created_at=>1335269478}],
                                        [:add_node_to_index, "person_ssn", "ssn", "000-00-0001", "{0}"],
                                        [:create_node, {:street1=>"94437 Kemmer Crossing", :street2=>"Apt. 333", :city=>"Abshireton", :state=>"AA", :zip=>"65820", :_type=>"Address", :created_at=>1335269478}],
                                        [:create_relationship, "has", "{0}", "{2}", {}]
            }.to raise_error(Neography::NeographyError)
            
      begin
        batch_result = @neo.batch [:create_unique_node, "person", "ssn", "000-00-0001", {:first_name=>"Jane", :last_name=>"Doe", :ssn=>"000-00-0001", :_type=>"Person", :created_at=>1335269478}],
                                  [:add_node_to_index, "person_ssn", "ssn", "000-00-0001", "{0}"],
                                  [:create_node, {:street1=>"94437 Kemmer Crossing", :street2=>"Apt. 333", :city=>"Abshireton", :state=>"AA", :zip=>"65820", :_type=>"Address", :created_at=>1335269478}],
                                  [:create_relationship, "has", "{0}", "{2}", {}]
      rescue Neography::NeographyError => e
        expect(e.message).to eq("Not Found")
        expect(e.code).to eq(404)
        expect(e.stacktrace).to be_nil
        expect(e.request[:path]).to eq("/db/data/batch")
        expect(e.request[:body]).not_to be_nil
        expect(e.index).to eq(3)
      end            
    end

  end

  describe "broken queries" do
    it "should return errors when bad syntax is passed in batch" do
      batch_commands = []

      batch_commands << [ :execute_query, "start person_n=node:person(ssn = '000-00-0002')
                                           set bar1 = {foo}",
                        { :other => "what" }
                      ]

      expect {
        batch_result = @neo.batch *batch_commands
      }.to raise_exception Neography::SyntaxException

      expect {
          @neo.execute_query("start person_n=node:person(ssn = '000-00-0001')
                              set bar = {foo}",
                        { :other => "what" })
      }.to raise_exception Neography::SyntaxException


    end
  end

  describe "batch unknown option" do
    it "should raise Neography::UnknownBatchOptionException when bad option is passed in batch" do
      batch_commands = []

      batch_commands << [ :bad_option, "start person_n=node:person(ssn = '000-00-0002')
                                           set bar1 = {foo}"]

      expect {
        batch_result = @neo.batch *batch_commands
      }.to raise_exception Neography::UnknownBatchOptionException

    end
  end

end
