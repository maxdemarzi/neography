require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  it "should not add a content-type header if there's no existing headers" do
    @neo.merge_options({}).keys.should == [:parser]
  end

  it "should add a content type if there's existing headers" do
    @neo.merge_options({:headers => {'Content-Type' => 'foo/bar'}})[:headers].should ==
      {'Content-Type' => "foo/bar",  "User-Agent"   => "Neography/#{Neography::VERSION}"}

  end


end
