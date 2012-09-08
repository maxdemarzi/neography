require 'spec_helper'

module Neography
  class Rest
    describe Gremlin do

      let(:connection) { stub(:gremlin_path => "/gremlin") }
      subject { Gremlin.new(connection) }

      it "executes a gremlin script" do
        options = {
          :body=>"{\"script\":\"SOME SCRIPT\",\"params\":{\"foo\":\"bar\",\"baz\":\"qux\"}}",
          :headers=>{"Content-Type"=>"application/json"}
        }
        connection.should_receive(:post).with("/gremlin", options)
        subject.execute("SOME SCRIPT", { :foo => "bar", :baz => "qux" })
      end

      it "returns nil if script result is null" do
        connection.stub(:post).and_return("null")
        subject.execute("", {}).should be_nil
      end

    end
  end
end
