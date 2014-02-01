require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "call unmanaged extensions", :unmanaged_extensions => true  do
    it "can call a get based unmanaged extension" do
      results = @neo.get_extension('/example/service/queries/fofof/13343')
      results.should_not be_null
    end
    
    it "can call a POST based unmanaged extension" do 
      results = @neo.post_extention('/movie/recommend', {"title" => "Rambo"})
      results.should_not be_null
    end
    
    it "can call a POST based unmanaged extension that uses form-urlencoded" do
      headers = {'Content-Type' =>'application/x-www-form-urlencoded'}
      results = @neo.post_extention('/music/recommend', {"artist" => "Ministry", "song" => "Just one Fix"}, headers)    
      results.should_not be_null
    end

  end

end