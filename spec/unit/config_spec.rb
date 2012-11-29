require 'spec_helper'

module Neography
  describe Config do

    subject(:config) { Config.new }

    context "defaults" do

      its(:protocol)       { should == 'http://' }
      its(:server)         { should == 'localhost' }
      its(:port)           { should == 7474 }
      its(:directory)      { should == '' }
      its(:cypher_path)    { should == '/cypher' }
      its(:gremlin_path)   { should == '/ext/GremlinPlugin/graphdb/execute_script' }
      its(:log_file)       { should == 'neography.log' }
      its(:log_enabled)    { should == false }
      its(:max_threads)    { should == 20 }
      its(:authentication) { should == nil }
      its(:username)       { should == nil }
      its(:password)       { should == nil }
      its(:parser)         { should == { :parser => MultiJsonParser } }

      it "has a hash representation" do
        expected_hash = {
          :protocol       => 'http://',
          :server         => 'localhost',
          :port           => 7474,
          :directory      => '',
          :cypher_path    => '/cypher',
          :gremlin_path   => '/ext/GremlinPlugin/graphdb/execute_script',
          :log_file       => 'neography.log',
          :log_enabled    => false,
          :max_threads    => 20,
          :authentication => nil,
          :username       => nil,
          :password       => nil,
          :parser         => { :parser => MultiJsonParser }
        }
        config.to_hash.should == expected_hash
      end

    end

  end
end
