require 'spec_helper'

module Neography
  class Rest
    describe NodeLabels do

      let(:connection) { double }
      subject { NodeLabels.new(connection) }

      it "list node labels" do
        connection.should_receive(:get).with("/labels")
        subject.list
      end

      it "get labels for node" do
        connection.should_receive(:get).with("/node/0/labels")
        subject.get(0)
      end

      it "get nodes for labels" do
        connection.should_receive(:get).with("/label/person/nodes")
        subject.get_nodes("person")
      end

      it "find nodes for labels and property string" do
        connection.should_receive(:get).with("/label/person/nodes?name=%22max%22")
        subject.find_nodes("person", {:name => "max"})
      end

      it "find nodes for labels and property integer" do
        connection.should_receive(:get).with("/label/person/nodes?age=26")
        subject.find_nodes("person", {:age => 26})
      end

      it "can add a label to a node" do
        options = {
          :body    => '["Actor"]',
          :headers => json_content_type
        }
        connection.should_receive(:post).with("/node/0/labels", options)
        subject.add(0, ["Actor"])
      end

      it "can add labels to a node" do
        options = {
          :body    => '["Actor","Director"]',
          :headers => json_content_type
        }
        connection.should_receive(:post).with("/node/0/labels", options)
        subject.add(0, ["Actor", "Director"])
      end

      it "can set a label to a node" do
        options = {
          :body    => '["Actor"]',
          :headers => json_content_type
        }
        connection.should_receive(:put).with("/node/0/labels", options)
        subject.set(0, ["Actor"])
      end

      it "can add labels to a node" do
        options = {
          :body    => '["Actor","Director"]',
          :headers => json_content_type
        }
        connection.should_receive(:put).with("/node/0/labels", options)
        subject.set(0, ["Actor", "Director"])
      end
      
      it "can delete a label from a node" do
        connection.should_receive(:delete).with("/node/0/labels/Actor")
        subject.delete(0,"Actor")
      end
      
    end
  end
end
