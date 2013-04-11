require 'spec_helper'

describe Neography::Rest, :slow => true do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "can perform" do
    it "is fast" do
      Benchmark.bm do |x|
        x.report(" 100 Times") {  100.times { @neo.create_node } }
        x.report(" 500 Times") {  500.times { @neo.create_node } }
        x.report("1000 Times") { 1000.times { @neo.create_node } }
      end
    end
  end
end
