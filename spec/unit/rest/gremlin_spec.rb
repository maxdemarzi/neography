require 'spec_helper'

module Neography
  class Rest
    describe Gremlin do

      subject { Neography::Rest.new }

      it "executes a gremlin script" do
        options = {
          :body=>"{\"script\":\"SOME SCRIPT\",\"params\":{\"foo\":\"bar\",\"baz\":\"qux\"}}",
          :headers=>{"Content-Type"=>"application/json"}
        }
        subject.connection.should_receive(:post).with("/ext/GremlinPlugin/graphdb/execute_script", options)
        subject.execute_script("SOME SCRIPT", { :foo => "bar", :baz => "qux" })
      end

      it "returns nil if script result is null" do
        subject.connection.stub(:post).and_return("null")
        subject.execute_script("", {}).should be_nil
      end

    end
  end
end
