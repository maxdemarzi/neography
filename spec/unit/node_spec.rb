require 'spec_helper'

module Neography
  describe Node do

    describe "::create" do
      context "no explicit server" do

        before do
          @db = double(Neography::Rest, :is_a? => true).as_null_object
          allow(Rest).to receive(:new) { @db }
        end

        it "assigns a new Rest db by default" do
          node = Node.create
          expect(node.neo_server).to eq(@db)
        end

        it "creates without arguments" do
          expect(@db).to receive(:create_node).with(nil)
          Node.create
        end

        it "creates with only a hash argument" do
          properties = { :foo => "bar" }
          expect(@db).to receive(:create_node).with(properties)
          Node.create(properties)
        end

        describe "labels" do
          let(:node){ Node.create }

          it "are only fetched once" do
            expect(@db).to receive(:get_node_labels).exactly(1).and_return []
            node.labels
            node.labels
          end

          it "cache can be set from the outside" do
            expect(@db).to_not receive(:get_node_labels)
            node.cached_labels = ["Bar"]

            expect(node.labels).to eq ["Bar"]
          end

          it "cache is invalidated when labels are set" do
            expect(@db).to receive(:get_node_labels).exactly(2).and_return []
            expect(@db).to receive(:set_label).exactly(1)
            node.labels
            node.set_labels("Something")
            node.labels
          end

          it "cache is invalidated when labels are set" do
            expect(@db).to receive(:get_node_labels).exactly(2).and_return []
            expect(@db).to receive(:add_label).exactly(1)
            node.labels
            node.add_labels("Something")
            node.labels
          end

          it "cache is invalidated when labels are deleted" do
            expect(@db).to receive(:get_node_labels).exactly(2).and_return []
            expect(@db).to receive(:delete_label).exactly(1)
            node.labels
            node.delete_label("Something")
            node.labels
          end

          describe "set" do
            it "as a single label" do
              expect(@db).to receive(:set_label).with(node, ["Foo"])
              node.set_label("Foo")
            end

            it "as an array" do
              expect(@db).to receive(:set_label).with(node, ["Foo"])
              node.set_labels(["Foo"])
            end
          end

          describe "add" do
            it "as a single label" do
              expect(@db).to receive(:add_label).with(node, ["Foo"])
              node.add_label("Foo")
            end

            it "as an array" do
              expect(@db).to receive(:add_label).with(node, ["Foo"])
              node.add_labels(["Foo"])
            end
          end

          it "can be deleted" do
            expect(@db).to receive(:delete_label).with(node, "Foo")
            node.delete_label("Foo")
          end
        end

      end

      context "explicit server" do

        it "cannot pass a server as the first argument, properties as the second (deprecated)" do
          @other_server = Neography::Rest.new
          properties = { :foo => "bar" }
          expect(@other_server).not_to receive(:create_node).with(properties)
          expect {
            Node.create(@other_server, properties)
          }.to raise_error(ArgumentError)
        end

        it "can pass properties as the first argument, a server as the second" do
          @other_server = Neography::Rest.new
          properties = { :foo => "bar" }
          expect(@other_server).to receive(:create_node).with(properties)
          Node.create(properties, @other_server)
        end

      end
    end

    describe "::load" do
      context "no explicit server" do

        before do
          # stub out actual connections
          @db = double(Rest).as_null_object
          allow(Rest).to receive(:new) { @db }
        end

        it "load by id" do
          expect(@db).to receive(:get_node).with(5)
          Node.load(5)
        end

        it "loads by node" do
          node = Node.new
          expect(@db).not_to receive(:get_node).with(node)
          Node.load(node)
        end

        it "loads by full server string" do
          expect(@db).to receive(:get_node).with("http://localhost:7474/db/data/node/2")
          Node.load("http://localhost:7474/db/data/node/2")
        end

      end

      context "explicit server" do

        it "cannot pass a server as the first argument, node as the second (deprecated)" do
          @other_server = Neography::Rest.new
          expect(@other_server).not_to receive(:get_node).with(42)
          expect {
            Node.load(@other_server, 42)
          }.to raise_error(ArgumentError)
        end

        it "can pass a node as the first argument, server as the second" do
          @other_server = Neography::Rest.new
          expect(@other_server).to receive(:get_node).with(42)
          Node.load(42, @other_server)
        end

      end
    end

  end
end
