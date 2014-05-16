require 'spec_helper'

describe Neography::Connection do

  it "should not add a content-type header if there's no existing headers" do
    expect(subject.merge_options({}).keys).to eq([])
  end

  it "should add a content type if there's existing headers" do
    expect(subject.merge_options({:headers => {'Content-Type' => 'foo/bar'}})[:headers]).to eq(
      {'Content-Type' => "foo/bar",  "User-Agent"   => "Neography/#{Neography::VERSION}" , "X-Stream"=>true, "max-execution-time"=>6000}
    )
  end

end
