require 'spec_helper'

module Neography
  class Rest
    describe Constraints do

      subject { Neography::Rest.new }

      it "list constraints" do
        expect(subject.connection).to receive(:get).with("/schema/constraint/")
        subject.get_constraints
      end

      it "get constraints for a label" do
        expect(subject.connection).to receive(:get).with("/schema/constraint/label")
        subject.get_constraints("label")
      end

      it "create a unique constraint for a label" do
        options = {
            :body    => '{"property_keys":["property"]}',
            :headers => json_content_type
          }
        expect(subject.connection).to receive(:post).with("/schema/constraint/label/uniqueness/", options)
        subject.create_unique_constraint("label", "property")
      end
      
      it "get unique constraints for a label" do
        expect(subject.connection).to receive(:get).with("/schema/constraint/label/uniqueness/")
        subject.get_uniqueness("label")
      end

      it "get a specific unique constraint for a label" do
        expect(subject.connection).to receive(:get).with("/schema/constraint/label/uniqueness/property")
        subject.get_unique_constraint("label", "property")
      end
      
      it "can delete a constraint for a label" do
        expect(subject.connection).to receive(:delete).with("/schema/constraint/label/uniqueness/property")
        subject.drop_constraint("label","property")
      end
      
    end
  end
end  