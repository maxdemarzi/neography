require 'spec_helper'

module Neography
  class Rest
    describe RelationshipTypes do

      let(:connection) { stub(:configuration => "http://configuration") }
      subject { RelationshipTypes.new(connection) }

      it "lists all relationship types" do
        connection.should_receive(:get).with("/relationship/types")
        subject.list
      end
    end
  end
end
