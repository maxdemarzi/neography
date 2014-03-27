require 'spec_helper'

module Neography
  class Rest
    describe Extensions do

      subject { Neography::Rest.new }

      it "executes an extensions get query" do
        path = "/unmanaged_extension/test"

        subject.connection.should_receive(:get).with(path)
        subject.get_extension("/unmanaged_extension/test")
      end

      it "executes an extensions post query" do
        path = "/unmanaged_extension/test"
        options = {
          :body=>"{\"foo\":\"bar\",\"baz\":\"qux\"}",
          :headers=>{"Content-Type"=>"application/json", "Accept"=>"application/json;stream=true"}
        }
        subject.connection.should_receive(:post).with(path, options)
        subject.post_extension("/unmanaged_extension/test", { :foo => "bar", :baz => "qux" })
      end

    end
  end
end
