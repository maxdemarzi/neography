require 'spec_helper'

module Neography
  class Rest
    describe Clean do

      let(:connection) { double }
      subject { Clean.new(connection) }

      it "cleans the database" do
        connection.should_receive(:delete).with("/cleandb/secret-key")
        subject.execute
      end

    end
  end
end
