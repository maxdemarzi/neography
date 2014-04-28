require 'spec_helper'

module Neography
  describe Connection do

    subject(:connection) { Connection.new }

    context "defaults" do

      it "intializes with defaults" do
        connection.configuration.should == "http://localhost:7474"
      end

    end

    context "custom options" do

      subject(:connection) { Connection.new(options) }

      context "hash options" do
        let(:options) do
          {
            :protocol           => "https://",
            :server             => "foobar",
            :port               => 4242,
            :directory          => "/dir",
            :cypher_path        => "/cyph",
            :gremlin_path       => "/grem",
            :log_file           => "neo.log",
            :log_enabled        => false,
            :slow_log_threshold => 0,
            :max_threads        => 10,
            :parser             => Foo,
            :authentication     => "foo",
            :username           => "bar",
            :password           => "baz"
          }
        end

        it "accepts all options in a hash" do
          connection.configuration.should == "https://foobar:4242/dir"

          connection.protocol.should           == "https://"
          connection.server.should             == "foobar"
          connection.port.should               == 4242
          connection.directory.should          == "/dir"
          connection.cypher_path.should        == "/cyph"
          connection.gremlin_path.should       == "/grem"
          connection.log_file.should           == "neo.log"
          connection.log_enabled.should        == false
          connection.slow_log_threshold.should == 0
          connection.max_threads.should        == 10
          connection.parser.should             == Foo

          connection.authentication.should == {
            :foo_auth => {
              :username => "bar",
              :password => "baz"
            }
          }
        end

        context "httpclient" do
          let(:httpclient) { double(:http_client) }
          let(:options) do
            {
              :http_send_timeout     => 120,
              :http_receive_timeout  => 100
            }
          end

          it 'configures send/receive timeout' do
            Excon.should_receive(:new).with("http://localhost:7474", 
                                    :read_timeout => 100, 
                                    :write_timeout => 120,
                                    :persistent=>true, 
                                    :user=>nil, 
                                    :password=>nil).and_return(httpclient)
            connection
          end
        end
      end



      context "string option" do
        let(:options) { "https://user:pass@somehost:8585/path" }

        it "accepts a string as configuration" do
          connection.configuration.should == "https://somehost:8585/path"
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
        connection.client.should_receive(:request).with(:method => :get, :path => "/db/data/node/bar", :body => nil, :headers => nil) { double.as_null_object }
        connection.get("/node/bar")
      end

      it "does a POST request" do
        connection.client.should_receive(:request).with(:method => :post, :path => "/db/data/node/bar", :body => nil, :headers => nil) { double.as_null_object }
        connection.post("/node/bar")
      end

      it "does a PUT request" do
        connection.client.should_receive(:request).with(:method => :put, :path => "/db/data/node/bar", :body => nil, :headers => nil) { double.as_null_object }
        connection.put("/node/bar")
      end

      it "does a DELETE request" do
        connection.client.should_receive(:request).with(:method => :delete, :path => "/db/data/node/bar", :body => nil, :headers => nil) { double.as_null_object }
        connection.delete("/node/bar")
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
          connection.client.should_not_receive(:set_auth).with(
            "http://localhost:7474/db/data/node/bar",
             "foo",
             "bar") { double.as_null_object }

          connection.client.should_receive(:request).with(
            :method => :get, :path => "/db/data/node/bar", :body => nil, :headers => nil) { double.as_null_object }

          connection.get("/node/bar")
        end
      end

      it "adds the User-Agent to the headers" do
        connection.client.should_receive(:request).with(
            hash_including(
                {:method => :get, :path => "/db/data/node/bar", :body => nil,
                 :headers => {"User-Agent" => "Neography/#{Neography::VERSION}", "X-Stream"=>true, "max-execution-time" => 6000}}
            )
        ) { double.as_null_object }

        connection.get("/node/bar", :headers => {})
      end

      context "errors" do

        it "raises NodeNotFoundException" do
          response = error_response(code: 404, message: "a message", exception: "NodeNotFoundException")
          connection.client.stub(:request).and_return(response)
          expect {
            connection.get("/node/bar")
          }.to raise_error NodeNotFoundException
        end

        it "raises OperationFailureException" do
          response = error_response(code: 409, message: "a message", exception: "OperationFailureException")
          connection.client.stub(:request).and_return(response)
          expect {
            connection.get("/node/bar")
          }.to raise_error OperationFailureException
        end

        it "raises PropertyValueException" do
          response = error_response(code: 400, message: "a message", exception: "PropertyValueException")
          connection.client.stub(:request).and_return(response)
          expect {
            connection.get("/node/bar")
          }.to raise_error PropertyValueException
        end

        it "raises NoSuchPropertyException" do
          response = error_response(code: 404, message: "a message", exception: "NoSuchPropertyException")
          connection.client.stub(:request).and_return(response)
          expect {
            connection.get("/node/bar")
          }.to raise_error NoSuchPropertyException
        end

        it "raises RelationshipNotFoundException" do
          response = error_response(code: 404, message: "a message", exception: "RelationshipNotFoundException")
          connection.client.stub(:request).and_return(response)
          expect {
            connection.get("/node/bar")
          }.to raise_error RelationshipNotFoundException
        end

        it "raises BadInputException" do
          response = error_response(code: 400, message: "a message", exception: "BadInputException")
          connection.client.stub(:request).and_return(response)
          expect {
            connection.get("/node/bar")
          }.to raise_error BadInputException
        end

        it "raises UnauthorizedError" do
          response = error_response(code: 401)
          connection.client.stub(:request).and_return(response)
          expect {
            connection.get("/node/bar")
          }.to raise_error UnauthorizedError
        end

        it "raises NeographyError in all other cases" do
          response = error_response(code: 418, message: "I'm a teapot.")
          connection.client.stub(:request).and_return(response)
          expect {
            connection.get("/node/bar")
          }.to raise_error NeographyError
        end

        it "raises BadInputException" do
          response = error_response(code: 500, message: "a message", exception: "JsonParseException")
          connection.client.stub(:request).and_return(response)
          expect {
            connection.get("/node/bar")
          }.to raise_error NeographyError
        end

      end

      context "query logging" do

        subject(:connection) do

          Connection.new({
            :logger => Logger.new(nil),
            :log_enabled => true
          })
        
          let(:expected_response) {"expected_response"}

          let(:request_body) { {key1: :val1} }

          it "should log query" do
            connection.should_receive(:log).with("/db/data/node/bar", request_body).once
            connection.get("/node/bar", {body: request_body})
          end

          it "should return original response" do
            connection.stub(:evaluate_response).and_return expected_response
            connection.get("/node/bar").should eq expected_response
          end

          describe "slow_log_threshold" do
            before do
              connection.stub(:evaluate_response).and_return expected_response
            end

            context "default value" do
              it "should have output" do
                @logger.should_receive(:info).once
              end
            end

            context "high value" do
              before { connection.slow_log_threshold = 100_000 }
              it "should not have output" do
                @logger.should_not_receive(:info)
              end
            end

            after do
              connection.get("/node/bar", {body: request_body})
            end
          end
        end
      end
    end
  end
end

class Foo; end
