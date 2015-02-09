require 'spec_helper'

module Neography
  describe Config do

    subject(:config) { Config.new }

    context "defaults" do

      describe '#protocol' do
        subject { super().protocol }
        it              { should == 'http' }
      end

      describe '#server' do
        subject { super().server }
        it                { should == 'localhost' }
      end

      describe '#port' do
        subject { super().port }
        it                  { should == 7474 }
      end

      describe '#directory' do
        subject { super().directory }
        it             { should == '' }
      end

      describe '#cypher_path' do
        subject { super().cypher_path }
        it           { should == '/cypher' }
      end

      describe '#gremlin_path' do
        subject { super().gremlin_path }
        it          { should == '/ext/GremlinPlugin/graphdb/execute_script' }
      end

      describe '#log_file' do
        subject { super().log_file }
        it              { should == 'neography.log' }
      end

      describe '#log_enabled' do
        subject { super().log_enabled }
        it           { should == false }
      end

      describe '#logger' do
        subject { super().logger }
        it                { should == nil }
      end

      describe '#slow_log_threshold' do
        subject { super().slow_log_threshold }
        it    { should == 0 }
      end

      describe '#max_threads' do
        subject { super().max_threads }
        it           { should == 20 }
      end

      describe '#authentication' do
        subject { super().authentication }
        it        { should == nil }
      end

      describe '#username' do
        subject { super().username }
        it              { should == nil }
      end

      describe '#password' do
        subject { super().password }
        it              { should == nil }
      end

      describe '#parser' do
        subject { super().parser }
        it                { should == MultiJsonParser}
      end

      describe '#max_execution_time' do
        subject { super().max_execution_time }
        it    { should == 6000 }
      end

      describe '#proxy' do
        subject { super().proxy }
        it                 { should == nil }
      end

      describe '#http_send_timeout' do
        subject { super().http_send_timeout }
        it     { should == 1200 }
      end

      describe '#http_receive_timeout' do
        subject { super().http_receive_timeout }
        it  { should == 1200 }
      end

      describe '#persistent' do
        subject { super().persistent }
        it { should == true }
      end


      it "has a hash representation" do
        expected_hash = {
          :protocol             => 'http',
          :server               => 'localhost',
          :port                 => 7474,
          :directory            => '',
          :cypher_path          => '/cypher',
          :gremlin_path         => '/ext/GremlinPlugin/graphdb/execute_script',
          :log_file             => 'neography.log',
          :log_enabled          => false,
          :logger               => nil,
          :slow_log_threshold   => 0,
          :max_threads          => 20,
          :authentication       => nil,
          :username             => nil,
          :password             => nil,
          :parser               => MultiJsonParser,
          :max_execution_time   => 6000,
          :proxy                => nil,
          :http_send_timeout    => 1200,
          :http_receive_timeout => 1200,
          :persistent           => true

        }
        expect(config.to_hash).to eq(expected_hash)
      end

    end

  end
end
