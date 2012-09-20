require 'spec_helper'

module Neography
  class Rest

    class Dummy
      extend Paths

      add_path :one, "/node/:id"
      add_path :two, "/node/:id/properties/:property"
    end

    describe Dummy do

      context "instance methods" do

        it { should respond_to(:one_path) }
        it { should respond_to(:two_path) }

        it "replaces a key" do
          subject.one_path(:id => 42).should == "/node/42"
        end

        it "replaces multiple keys" do
          subject.two_path(:id => 42, :property => "foo").should == "/node/42/properties/foo"
        end

        it "url encodes spaces" do
          subject.one_path(:id => "with space").should == "/node/with%20space"
        end

        # URI.encode does not escape slashes (and rightly so), but should escape these keys
        it "url encodes slashes" do
          subject.one_path(:id => "with/slash").should == "/node/with%2Fslash"
        end

      end

      context "class methods" do

        subject { Dummy }

        it { should respond_to(:one_path) }
        it { should respond_to(:two_path) }

        it "replaces a key" do
          subject.one_path(:id => 42).should == "/node/42"
        end

        it "replaces multiple keys" do
          subject.two_path(:id => 42, :property => "foo").should == "/node/42/properties/foo"
        end

        it "url encodes spaces" do
          subject.one_path(:id => "with space").should == "/node/with%20space"
        end

        # URI.encode does not escape slashes (and rightly so), but should escape these keys
        it "url encodes slashes" do
          subject.one_path(:id => "with/slash").should == "/node/with%2Fslash"
        end

      end

    end

  end
end

