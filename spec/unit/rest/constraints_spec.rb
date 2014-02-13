require 'spec_helper'

module Neography
  class Rest
    describe Constraints do

      let(:connection) { double }
      subject { Constraints.new(connection) }

      it "list constraints" do
        connection.should_receive(:get).with("/schema/constraint/")
        subject.list
      end

      it "get constraints for a label" do
        connection.should_receive(:get).with("/schema/constraint/label")
        subject.get("label")
      end

      it "create a unique constraint for a label" do
        options = {
            :body    => '{"property_keys":["property"]}',
            :headers => json_content_type
          }
        connection.should_receive(:post).with("/schema/constraint/label/uniqueness/", options)
        subject.create_unique("label", "property")
      end
      
      it "get unique constraints for a label" do
        connection.should_receive(:get).with("/schema/constraint/label/uniqueness/")
        subject.get_uniqueness("label")
      end

      it "get a specific unique constraint for a label" do
        connection.should_receive(:get).with("/schema/constraint/label/uniqueness/property")
        subject.get_unique("label", "property")
      end
      
      it "can delete a constraint for a label" do
        connection.should_receive(:delete).with("/schema/constraint/label/uniqueness/property")
        subject.drop("label","property")
      end
      
    end
  end
end  