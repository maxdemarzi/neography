require 'spec_helper'

module Neography
  describe "Properties" do

    before do
      @db = double(Neography::Rest, :is_a? => true).as_null_object
      allow(Rest).to receive(:new) { @db }
    end

    context "Node" do

      subject(:node) do
        node = Node.create
        allow(node).to receive(:neo_id).and_return(42)
        node
      end

      it "sets properties as accessor" do
        expect(@db).to receive(:"set_node_properties").with(42, { "key" => "value" })
        node.key = "value"
      end

      it "sets properties as array entry" do
        expect(@db).to receive(:"set_node_properties").with(42, { "key" => "value" })
        node["key"] = "value"
      end

      it "gets properties as accessor" do
        allow(@db).to receive(:"set_node_properties")
        node.key = "value"
        expect(node.key).to eq("value")
      end

      it "gets properties as array entry" do
        allow(@db).to receive(:"set_node_properties")
        node["key"] = "value"
        expect(node["key"]).to eq("value")
      end

      it "resets properties as accessor" do
        expect(@db).to receive(:"remove_node_properties").with(42, ["key"])
        node.key = "value"
        node.key = nil
      end

      it "resets properties as array entry" do
        expect(@db).to receive(:"remove_node_properties").with(42, ["key"])
        node["key"] = "value"
        node["key"] = nil
      end

      it "gets unknown properties as nil" do
        expect(node.unknown).to eq(nil)
      end

      it "overwrites existing properties" do
        expect(@db).to receive(:"set_node_properties").with(42, { "key" => "value1" })
        node.key = "value1"

        expect(@db).to receive(:"set_node_properties").with(42, { "key" => "value2" })
        node.key = "value2"
      end

      it "knows its attributes" do
        allow(@db).to receive(:"set_node_properties")
        node.key = "value"
        node["key2"] = "value"
        expect(node.attributes).to match_array([ :key, :key2 ])
      end

      describe "resets all node properties with one http request" do
        before(:each) do
          @change_node = Node.create

          # A property that we will overwrite
          @change_node[:old_key] = 'value'

          # Stub neo id
          allow(@change_node).to receive(:neo_id).and_return(22)

          # What we call set_properties with
          @new_data = { new_key: "new value"}

          # Make sure the request is dispatched to the rest layer
          expect(@db).to receive(:reset_node_properties).with(22, @new_data)
        end

        it "removes the old property getter" do
          expect{
            @change_node.reset_properties(@new_data)
          }.to change{@change_node.respond_to?(:old_key)}.from(true).to(false)
        end

        it "removes the old property setter" do
          expect{
            @change_node.reset_properties(@new_data)
          }.to change{@change_node.respond_to?('old_key=')}.from(true).to(false)
        end

        it "removes the property from the underlying openstruct" do
          expect{
            @change_node.reset_properties(@new_data)
          }.to change{@change_node['old_key']}.from('value').to(nil)
        end

        it "adds the new property getter" do
          expect{
            @change_node.reset_properties(@new_data)
          }.to change{@change_node.respond_to?(:new_key)}.from(false).to(true)
        end

        it "adds the new property setter" do
          expect{
            @change_node.reset_properties(@new_data)
          }.to change{@change_node.respond_to?('new_key=')}.from(false).to(true)
        end

        it "adds the new property to the underlying openstruct" do
          expect{
            @change_node.reset_properties(@new_data)
          }.to change{@change_node['new_key']}.from(nil).to('new value')
        end

        it "updates its attributes" do
          expect{
            @change_node.reset_properties(@new_data)
          }.to change{@change_node.attributes}.from([:old_key]).to([:new_key])
        end
      end


      describe "sets all node properties with one http request" do
        before(:each) do
          @change_node = Node.create

          # A property that we will overwrite
          @change_node[:old_key] = 'value'

          # A property that we will not overwrite and that must stay
          @change_node[:old_remaining_key] = 'remaining value'

          # Stub neo id
          allow(@change_node).to receive(:neo_id).and_return(22)

          # What we call set_properties with
          @new_data = { "new_key" => "new value", 'old_key' => nil }

          # What we expect neography to send as the new properties
          update_data = { new_key: 'new value', old_remaining_key: 'remaining value'}

          # Make sure the request is dispatched to the rest layer
          expect(@db).to receive(:reset_node_properties).with(22, update_data)
        end

        it "removes the old property getter" do
          expect{
            @change_node.set_properties(@new_data)
          }.to change{@change_node.respond_to?(:old_key)}.from(true).to(false)
        end

        it "removes the old property setter" do
          expect{
            @change_node.set_properties(@new_data)
          }.to change{@change_node.respond_to?('old_key=')}.from(true).to(false)
        end

        it "removes the property from the underlying openstruct" do
          expect{
            @change_node.set_properties(@new_data)
          }.to change{@change_node['old_key']}.from('value').to(nil)
        end

        it "doesn't touch the remaining property in the openstruct" do
          expect{
            @change_node.set_properties(@new_data)
          }.to_not change{@change_node['old_remaining_key']}
        end

        it "doesn't touch the remaining property getter" do
          expect{
            @change_node.set_properties(@new_data)
          }.to_not change{@change_node.respond_to?(:old_remaining_key)}
        end

        it "doesn't touch the remaining property setter" do
          expect{
            @change_node.set_properties(@new_data)
          }.to_not change{@change_node.respond_to?('old_remaining_key=')}
        end

        it "adds the new property getter" do
          expect{
            @change_node.set_properties(@new_data)
          }.to change{@change_node.respond_to?(:new_key)}.from(false).to(true)
        end

        it "adds the new property setter" do
          expect{
            @change_node.set_properties(@new_data)
          }.to change{@change_node.respond_to?('new_key=')}.from(false).to(true)
        end

        it "adds the new property to the underlying openstruct" do
          expect{
            @change_node.set_properties(@new_data)
          }.to change{@change_node['new_key']}.from(nil).to('new value')
        end

        it "updates its attributes" do
          expect{
            @change_node.set_properties(@new_data)
          }.to change{@change_node.attributes}.from([:old_key, :old_remaining_key]).to([:old_remaining_key, :new_key])
        end
      end

    end

    context "Relationship" do

      subject(:relationship) do
        from = Node.create
        to = Node.create

        rel = Relationship.create(:type, from, to)
        allow(rel).to receive(:neo_id).and_return(42)
        rel
      end

      it "sets properties as accessor" do
        expect(@db).to receive(:"set_relationship_properties").with(42, { "key" => "value" })
        relationship.key = "value"
      end

      it "sets properties as array entry" do
        expect(@db).to receive(:"set_relationship_properties").with(42, { "key" => "value" })
        relationship["key"] = "value"
      end

      it "gets properties as accessor" do
        allow(@db).to receive(:"set_relationship_properties")
        relationship.key = "value"
        expect(relationship.key).to eq("value")
      end

      it "gets properties as array entry" do
        allow(@db).to receive(:"set_relationship_properties")
        relationship["key"] = "value"
        expect(relationship["key"]).to eq("value")
      end

      it "resets properties as accessor" do
        expect(@db).to receive(:"remove_relationship_properties").with(42, ["key"])
        relationship.key = "value"
        relationship.key = nil
      end

      it "resets properties as array entry" do
        expect(@db).to receive(:"remove_relationship_properties").with(42, ["key"])
        relationship["key"] = "value"
        relationship["key"] = nil
      end

      it "gets unknown properties as nil" do
        expect(relationship.unknown).to eq(nil)
      end

      it "overwrites existing properties" do
        expect(@db).to receive(:"set_relationship_properties").with(42, { "key" => "value1" })
        relationship.key = "value1"

        expect(@db).to receive(:"set_relationship_properties").with(42, { "key" => "value2" })
        relationship.key = "value2"
      end

      it "knows its attributes" do
        allow(@db).to receive(:"set_relationship_properties")
        relationship.key = "value"
        relationship["key2"] = "value"
        expect(relationship.attributes).to match_array([ :key, :key2 ])
      end

    end
  end
end
