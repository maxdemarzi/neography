require 'spec_helper'

module Neography
  class Rest
    describe Relationships do

      subject { Neography::Rest.new }

      it "gets a relationship" do
        subject.connection.should_receive(:get).with("/relationship/42")
        subject.get_relationship("42")
      end

      it "deletes a relationship" do
        subject.connection.should_receive(:delete).with("/relationship/42")
        subject.delete_relationship("42")
      end

    end
  end
end
