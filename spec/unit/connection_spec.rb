require 'spec_helper'

module Neography
  describe Connection do

    subject(:connection)

    context "defaults" do

      it "intializes with defaults" do
        connection.configuration.should == "http://localhost:7474/db/data"
      end

    end

    context "custom options" do

      subject(:connection) { Connection.new(options) }

      context "hash options" do
        let(:options) do
          {
            :protocol       => "https://",
            :server         => "foobar",
            :port           => 4242,
            :directory      => "/dir",
            :cypher_path    => "/cyph",
            :gremlin_path   => "/grem",
            :log_file       => "neo.log",
            :log_enabled    => false,
            :max_threads    => 10,
            :parser         => Foo,
            :authentication => "foo",
            :username       => "bar",
            :password       => "baz"
          }
        end

        it "accepts all options in a hash" do
          connection.configuration.should == "https://foobar:4242/dir/db/data"

          connection.protocol.should     == "https://"
          connection.server.should       == "foobar"
          connection.port.should         == 4242
          connection.directory.should    == "/dir"
          connection.cypher_path.should  == "/cyph"
          connection.gremlin_path.should == "/grem"
          connection.log_file.should     == "neo.log"
          connection.log_enabled.should  == false
          connection.max_threads.should  == 10
          connection.parser.should       == Foo

          connection.authentication.should == {
            :foo_auth => {
              :username => "bar",
              :password => "baz"
            }
          }
        end
      end

      context "string option" do
        let(:options) { "https://user:pass@somehost:8585/path" }

        it "accepts a string as configuration" do
          connection.configuration.should == "https://somehost:8585/path/db/data"
          connection.authentication.should == {
            :basic_auth => {
              :username => "user",
              :password => "pass"
            }
          }
        end
      end

    end

    context "requests" do

      it "does a GET request" do
        HTTParty.should_receive(:get).with("http://localhost:7474/db/data/foo/bar", { :parser => MultiJsonParser }) { stub.as_null_object }
        connection.get("/foo/bar")
      end

      it "does a POST request" do
        HTTParty.should_receive(:post).with("http://localhost:7474/db/data/foo/bar", { :parser => MultiJsonParser }) { stub.as_null_object }
        connection.post("/foo/bar")
      end

      it "does a PUT request" do
        HTTParty.should_receive(:put).with("http://localhost:7474/db/data/foo/bar", { :parser => MultiJsonParser }) { stub.as_null_object }
        connection.put("/foo/bar")
      end

      it "does a DELETE request" do
        HTTParty.should_receive(:delete).with("http://localhost:7474/db/data/foo/bar", { :parser => MultiJsonParser }) { stub.as_null_object }
        connection.delete("/foo/bar")
      end

      context "authentication" do
        subject(:connection) do
          Connection.new({
            :authentication => "basic",
            :username       => "foo",
            :password       => "bar"
          })
        end

        it "does requests with authentication" do
          HTTParty.should_receive(:get).with(
            "http://localhost:7474/db/data/foo/bar",
            { :parser => MultiJsonParser,
              :basic_auth => {
                :username => "foo",
                :password => "bar"
              }
            }) { stub.as_null_object }

          connection.get("/foo/bar")
        end
      end

      it "adds the User-Agent to the headers" do
        HTTParty.should_receive(:get).with(
          "http://localhost:7474/db/data/foo/bar",
          { :parser => MultiJsonParser,
            :headers => { "User-Agent" => "Neography/#{Neography::VERSION}" }
          }) { stub.as_null_object }

        connection.get("/foo/bar", :headers => {})
      end

    end
  end
end

class Foo; end
