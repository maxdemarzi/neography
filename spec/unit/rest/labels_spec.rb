require 'spec_helper'

module Neography
  class Rest
    describe NodeLabels do

      subject { Neography::Rest.new }

      it "list node labels" do
        expect(subject.connection).to receive(:get).with("/labels")
        subject.list_labels
      end

      it "get labels for node" do
        expect(subject.connection).to receive(:get).with("/node/0/labels")
        subject.get_node_labels(0)
      end

      it "get nodes for labels" do
        expect(subject.connection).to receive(:get).with("/label/person/nodes")
        subject.get_nodes_labeled("person")
      end

      it "find nodes for labels and property string" do
        expect(subject.connection).to receive(:get).with("/label/person/nodes?name=%22max%22")
        subject.find_nodes_labeled("person", {:name => "max"})
      end

      it "find nodes for labels and property integer" do
        expect(subject.connection).to receive(:get).with("/label/person/nodes?age=26")
        subject.find_nodes_labeled("person", {:age => 26})
      end

      it "can add a label to a node" do
        options = {
          :body    => '["Actor"]',
          :headers => json_content_type
        }
        expect(subject.connection).to receive(:post).with("/node/0/labels", options)
        subject.add_label(0, ["Actor"])
      end

      it "can add labels to a node" do
        options = {
          :body    => '["Actor","Director"]',
          :headers => json_content_type
        }
        expect(subject.connection).to receive(:post).with("/node/0/labels", options)
        subject.add_label(0, ["Actor", "Director"])
      end

      it "can set a label to a node" do
        options = {
          :body    => '["Actor"]',
          :headers => json_content_type
        }
        expect(subject.connection).to receive(:put).with("/node/0/labels", options)
        subject.set_label(0, ["Actor"])
      end

      it "can add labels to a node" do
        options = {
          :body    => '["Actor","Director"]',
          :headers => json_content_type
        }
        expect(subject.connection).to receive(:put).with("/node/0/labels", options)
        subject.set_label(0, ["Actor", "Director"])
      end
      
      it "can delete a label from a node" do
        expect(subject.connection).to receive(:delete).with("/node/0/labels/Actor")
        subject.delete_label(0,"Actor")
      end
      
    end
  end
end
