require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end
  
  describe "streaming" do
  
    it "can send a 1000 item batch" do
      commands = []
      1000.times do |x|
        commands << [:create_node, {"name" => "Max " + x.to_s}]
      end
      batch_result = @neo.batch *commands
      batch_result.first["body"]["data"]["name"].should == "Max 0"
      batch_result.last["body"]["data"]["name"].should == "Max 999"
    end  

    it "can send a 10000 item batch" do
      commands = []
      10000.times do |x|
        commands << [:get_node, 0]
      end
      batch_result = @neo.batch *commands
      batch_result.first["body"]["self"].split('/').last.should == "0"
      batch_result.last["body"]["self"].split('/').last.should == "0"
    end  

  end

end
