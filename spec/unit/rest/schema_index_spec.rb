require 'spec_helper'

module Neography
  class Rest
    describe SchemaIndexes do

      subject { Neography::Rest.new }

      it "create schema indexes" do
        options = {
          :body    => '{"property_keys":["name"]}',
          :headers => json_content_type
        }
        subject.connection.should_receive(:post).with("/schema/index/person", options)
        subject.create_schema_index("person", ["name"])
      end

      it "get schema indexes" do
        subject.connection.should_receive(:get).with("/schema/index/person")
        subject.get_schema_index("person")
      end
      
      it "delete schema indexes" do
        subject.connection.should_receive(:delete).with("/schema/index/person/name")
        subject.delete_schema_index("person","name")
      end
      
    end
  end
end
