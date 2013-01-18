require 'spec_helper'

module Neography
  class Rest
    describe Extensions do

      let(:connection)  { stub }
      subject { Extensions.new(connection) }

      it "executes an extensions get query" do
        path = "/unmanaged_extension/test"

        connection.should_receive(:get).with(path)
        subject.get("/unmanaged_extension/test")
      end

      it "executes an extensions post query" do
        path = "/unmanaged_extension/test"
        options = {
          :body=>"{\"foo\":\"bar\",\"baz\":\"qux\"}",
          :headers=>{"Content-Type"=>"application/json", "Accept"=>"application/json;stream=true"}
        }
        connection.should_receive(:post).with(path, options)
        subject.post("/unmanaged_extension/test", { :foo => "bar", :baz => "qux" })
      end

    end
  end
end
