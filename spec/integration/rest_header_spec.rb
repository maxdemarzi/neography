require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  it "should not add a content-type header if there's no existing headers" do
    @neo.merge_options({}).should == {:parser => OjParser}
  end

  it "should add a content type if there's existing headers" do
    @neo.merge_options({:headers => {'Content-Type' => 'foo/bar'}}).should ==
                       {:headers => {'Content-Type' => "foo/bar",
                                    "User-Agent"   => "Neography/#{Neography::VERSION}"},
                                    :parser => OjParser}
  end


end
