require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Node do

  describe "find JSON parsing error" do
    it "can create a node with one normal property" do
      new_node = Neography::Node.create("name" => "Max")
      new_node.name.should == "Max"
    end

    it "can create a node with test_array" do
      test_array = {"fb_first_name"=>"Meital", 
                    "fb_id"=>"643", 
                    "fb_pic"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/50124_643972588_1517286203_n.jpg", "fb_token"=>"AZCVFyerYW6UNbOdOywlzkUrFZAiBUFbIM4kMLBIbZB8jiDDF9dQw", "register"=>true, "create_date"=>"2012-06-04 19:28:02 UTC", "notifications"=>true, "fb_pic_small"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/50124_643972588_1517286203_t.jpg", 
                    "work_email"=>"meital@workwith.me", 
                    "admin"=>false, 
                    "validation_context"=>nil}
      new_node = Neography::Node.create(test_array)
      new_node.fb_first_name.should == "Meital"
    end

    it "can update a node with test_array" do
      test_array = {"fb_first_name"=>"Meital", 
                    "fb_id"=>"643", 
                    "fb_pic"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/50124_643972588_1517286203_n.jpg", "fb_token"=>"AZCVFyerYW6UNbOdOywlzkUrFZAiBUFbIM4kMLBIbZB8jiDDF9dQw", "register"=>true, "create_date"=>"2012-06-04 19:28:02 UTC", "notifications"=>true, "fb_pic_small"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/50124_643972588_1517286203_t.jpg", 
                    "work_email"=>"meital@workwith.me", 
                    "admin"=>false, 
                    "validation_context"=>nil}
      new_node = Neography::Node.create("fb_first_name" => "Max")
      new_node.fb_first_name.should == "Max"
      @neo = Neography::Rest.new
      result = @neo.set_node_properties(new_node, test_array)
      double_check = @neo.get_node(new_node)
      double_check["self"].split('/').last.should == new_node.neo_id
    end

  end
end