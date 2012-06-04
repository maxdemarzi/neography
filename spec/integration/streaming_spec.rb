require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  it "can batch a bunch of nodes streaming" do
    commands = 500.times.collect{|x| [:create_node, {:name => "node-#{x}"}]}   
      Benchmark.bm do |x|
        x.report("batch           ") { @new_nodes = @neo.batch_not_streaming *commands }
        x.report("streaming batch ") { @new_nodes_streaming = @neo.batch *commands }
      end
      @new_nodes.should_not be_nil
      @new_nodes_streaming.should_not be_nil
      pending
  end
  
end