require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new(:log_enabled => true)
  end
  
  describe "can spatial plugin" do    
    it "can do spatial in batch", :neo_is_broken => true  do
      properties = {:lat => 60.1, :lon => 15.2}
      node = @neo.create_node(properties)
      batch_result = @neo.batch [:add_point_layer, "restaurantsbatch"],
                                [:add_node_to_layer, "restaurantsbatch", node],
                                [:get_layer, "restaurantsbatch"],
                                [:find_geometries_within_distance, "restaurantsbatch", 60.0,15.0, 100.0],
                                [:find_geometries_in_bbox, "restaurantsbatch", 60.0, 60.2, 15.0, 15.3]
      # getting "The transaction is marked for rollback only." errors
      # possibly related to a Cypher Transaction Bug.
      puts batch_result.inspect
      expect(batch_result[0].first["data"]["layer"]).to eq("restaurantsbatch")
      expect(batch_result[1].first["data"]["lat"]).to eq(properties[:lat])
      expect(batch_result[1].first["data"]["lon"]).to eq(properties[:lon])
      expect(batch_result[2].first["data"]["layer"]).to eq("restaurantsbatch")
      expect(batch_result[3].first["data"]).not_to be_empty
      expect(batch_result[4].first["data"]).not_to be_empty
    end
  end
end