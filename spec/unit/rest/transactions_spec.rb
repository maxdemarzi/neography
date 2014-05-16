require 'spec_helper'

module Neography
  class Rest
    describe Transactions do

      subject { Neography::Rest.new }
      
      it "can create new transactions" do
        options = {
          :body    => '{"statements":[]}',
          :headers => json_content_type
        }
        expect(subject.connection).to receive(:post).with("/transaction", options)
        subject.begin_transaction
      end

      it "can add to transactions" do
        options = {
          :body    => '{"statements":[]}',
          :headers => json_content_type
        }
        expect(subject.connection).to receive(:post).with("/transaction/1", options)
        subject.in_transaction(1, [])
      end

      it "can commit transactions" do
        options = {
          :body    => '{"statements":[]}',
          :headers => json_content_type
        }
        expect(subject.connection).to receive(:post).with("/transaction/1/commit", options)
        subject.commit_transaction(1, [])
      end

      it "can rollback transactions" do
        expect(subject.connection).to receive(:delete).with("/transaction/1")
        subject.rollback_transaction(1)
      end
      
    end
  end
end
