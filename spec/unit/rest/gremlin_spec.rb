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
        expect(subject.connection).to receive(:post).with("/ext/GremlinPlugin/graphdb/execute_script", options)
        subject.execute_script("SOME SCRIPT", { :foo => "bar", :baz => "qux" })
      end

      it "returns nil if script result is null" do
        allow(subject.connection).to receive(:post).and_return("null")
        expect(subject.execute_script("", {})).to be_nil
      end

    end
  end
end
