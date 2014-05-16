require 'spec_helper'

module Neography
  class Rest
    describe RelationshipTypes do

      subject { Neography::Rest.new }

      it "lists all relationship types" do
        expect(subject.connection).to receive(:get).with("/relationship/types")
        subject.list_relationship_types
      end
    end
  end
end
