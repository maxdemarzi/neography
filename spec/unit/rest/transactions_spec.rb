require 'spec_helper'

module Neography
  class Rest
    describe Transactions do

      let(:connection) { stub(:configuration => "http://configuration") }
      subject { Transactions.new(connection) }

      it "can create new transactions" do
        options = {
          :body    => '{"statements":[]}',
          :headers => json_content_type
        }
        connection.should_receive(:post).with("/transaction", options)
        subject.begin
      end

      it "can add to transactions" do
        options = {
          :body    => '{"statements":[]}',
          :headers => json_content_type
        }
        connection.should_receive(:post).with("/transaction/1", options)
        subject.add(1, [])
      end

      it "can commit transactions" do
        options = {
          :body    => '{"statements":[]}',
          :headers => json_content_type
        }
        connection.should_receive(:post).with("/transaction/1/commit", options)
        subject.commit(1, [])
      end

      it "can rollback transactions" do
        connection.should_receive(:delete).with("/transaction/1")
        subject.rollback(1)
      end
      
    end
  end
end
