require 'spec_helper'

module Neography
  class Rest
    describe SchemaIndexes do

      let(:connection) { stub(:configuration => "http://configuration") }
      subject { SchemaIndexes.new(connection) }

      it "create schema indexes" do
        options = {
          :body    => '{"property_keys":["name"]}',
          :headers => json_content_type
        }
        connection.should_receive(:post).with("/schema/index/person", options)
        subject.create("person", ["name"])
      end

      it "get schema indexes" do
        connection.should_receive(:get).with("/schema/index/person")
        subject.list("person")
      end
      
      it "delete schema indexes" do
        connection.should_receive(:delete).with("/schema/index/person/name")
        subject.drop("person","name")
      end
      
    end
  end
end
