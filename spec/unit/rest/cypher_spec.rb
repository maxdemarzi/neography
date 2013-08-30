require 'spec_helper'

module Neography
  class Rest
    describe Cypher do

      let(:connection) { double(:cypher_path => "/cypher") }
      subject { Cypher.new(connection) }

      it "executes a cypher query" do
        options = {
          :body=>"{\"query\":\"SOME QUERY\",\"params\":{\"foo\":\"bar\",\"baz\":\"qux\"}}",
          :headers=>{"Content-Type"=>"application/json", "Accept"=>"application/json;stream=true;charset=UTF-8"}
        }
        connection.should_receive(:post).with("/cypher", options)
        subject.query("SOME QUERY", { :foo => "bar", :baz => "qux" })
      end

    end
  end
end
