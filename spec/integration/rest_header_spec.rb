require 'spec_helper'

describe Neography::Connection do

  it "should not add a content-type header if there's no existing headers" do
    subject.merge_options({}).keys.should == []
  end

  it "should add a content type if there's existing headers" do
    subject.merge_options({:headers => {'Content-Type' => 'foo/bar'}})[:headers].should ==
      {'Content-Type' => "foo/bar",  "User-Agent"   => "Neography/#{Neography::VERSION}"}
  end

end
