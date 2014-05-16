require 'spec_helper'

module Neography
  class Rest
    describe Cypher do

      subject { Neography::Rest.new }

      it "executes a cypher query" do
        options = {
          :body=>"{\"query\":\"SOME QUERY\",\"params\":{\"foo\":\"bar\",\"baz\":\"qux\"}}",
          :headers=>{"Content-Type"=>"application/json", "Accept"=>"application/json;stream=true;charset=UTF-8"}
        }
        expect(subject.connection).to receive(:post).with("/cypher", options)
        subject.execute_query("SOME QUERY", { :foo => "bar", :baz => "qux" })
      end

    end
  end
end
