require 'spec_helper'

module Neography
  class Rest
    describe Relationships do

      let(:connection) { stub }
      subject { Relationships.new(connection) }

      it "gets a relationship" do
        connection.should_receive(:get).with("/relationship/42")
        subject.get("42")
      end

      it "deletes a relationship" do
        connection.should_receive(:delete).with("/relationship/42")
        subject.delete("42")
      end

    end
  end
end
