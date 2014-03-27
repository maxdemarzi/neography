require 'spec_helper'

module Neography
  class Rest
    describe Helpers do

      subject { Neography::Rest.new }

      context "directions" do

        [ :incoming, "incoming", :in, "in" ].each do |direction|
          it "parses 'in' direction" do
            subject.parse_direction(direction).should == "in"
          end
        end

        [ :outgoing, "outgoing", :out, "out" ].each do |direction|
          it "parses 'out' direction" do
            subject.parse_direction(direction).should == "out"
          end
        end

        it "parses 'all' direction by default" do
          subject.parse_direction("foo").should == "all"
        end

      end


    end
  end
end
