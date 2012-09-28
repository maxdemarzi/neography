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

      context "errors" do

        it "raises NodeNotFoundException" do
          response = error_response(code: 404, message: "a message", exception: "NodeNotFoundException")
          HTTParty.stub(:get).and_return(response)
          expect {
            connection.get("/foo/bar")
          }.to raise_error NodeNotFoundException
        end

        it "raises OperationFailureException" do
          response = error_response(code: 409, message: "a message", exception: "OperationFailureException")
          HTTParty.stub(:get).and_return(response)
          expect {
            connection.get("/foo/bar")
          }.to raise_error OperationFailureException
        end

        it "raises PropertyValueException" do
          response = error_response(code: 400, message: "a message", exception: "PropertyValueException")
          HTTParty.stub(:get).and_return(response)
          expect {
            connection.get("/foo/bar")
          }.to raise_error PropertyValueException
        end

        it "raises NoSuchPropertyException" do
          response = error_response(code: 404, message: "a message", exception: "NoSuchPropertyException")
          HTTParty.stub(:get).and_return(response)
          expect {
            connection.get("/foo/bar")
          }.to raise_error NoSuchPropertyException
        end

        it "raises RelationshipNotFoundException" do
          response = error_response(code: 404, message: "a message", exception: "RelationshipNotFoundException")
          HTTParty.stub(:get).and_return(response)
          expect {
            connection.get("/foo/bar")
          }.to raise_error RelationshipNotFoundException
        end

        it "raises BadInputException" do
          response = error_response(code: 400, message: "a message", exception: "BadInputException")
          HTTParty.stub(:get).and_return(response)
          expect {
            connection.get("/foo/bar")
          }.to raise_error BadInputException
        end

        it "raises UnauthorizedError" do
          response = error_response(code: 401)
          HTTParty.stub(:get).and_return(response)
          expect {
            connection.get("/foo/bar")
          }.to raise_error UnauthorizedError
        end

        it "raises NeographyError in all other cases" do
          response = error_response(code: 418, message: "I'm a teapot.")
          HTTParty.stub(:get).and_return(response)
          expect {
            connection.get("/foo/bar")
          }.to raise_error NeographyError
        end

      end

    end
  end
end

class Foo; end
