require 'spec_helper'

module Neography
  class Rest
    describe Clean do

      subject { Neography::Rest.new }

      it "cleans the database" do
        expect(subject.connection).to receive(:delete).with("/cleandb/secret-key")
        subject.clean_database("yes_i_really_want_to_clean_the_database")
      end

    end
  end
end
