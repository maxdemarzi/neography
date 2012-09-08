module Neography
  class Rest
    class Batch
      include Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :batch_path, "/batch"

      def initialize(connection)
        @connection = connection
      end

      def execute(*args)
        batch({'Accept' => 'application/json;stream=true'}, *args)
      end

      def not_streaming(*args)
        batch({}, *args)
      end

      private

      def batch(accept_header, *args)
        batch = []
        Array(args).each_with_index do |c,i|
          batch << {:id => i }.merge(get_batch(c))
        end
        options = {
          :body => batch.to_json,
          :headers => json_content_type.merge(accept_header)
        }

        @connection.post(batch_path, options)
      end

      def get_batch(args)
        case args[0]
          when :get_node
            {:method => "GET", :to => "/node/#{get_id(args[1])}"}
          when :create_node
            {:method => "POST", :to => "/node/", :body => args[1]}
          when :create_unique_node
            {:method => "POST", :to => "/index/node/#{args[1]}?unique", :body => {:key => args[2], :value => args[3], :properties => args[4]}}
          when :set_node_property
            {:method => "PUT", :to => "/node/#{get_id(args[1])}/properties/#{args[2].keys.first}", :body => args[2].values.first}
          when :reset_node_properties
            {:method => "PUT", :to => "/node/#{get_id(args[1])}/properties", :body => args[2]}
          when :get_relationship
            {:method => "GET", :to => "/relationship/#{get_id(args[1])}"}
          when :create_relationship
            {:method => "POST", :to => (args[2].is_a?(String) && args[2].start_with?("{") ? "" : "/node/") + "#{get_id(args[2])}/relationships", :body => {:to => (args[3].is_a?(String) && args[3].start_with?("{") ? "" : "/node/") + "#{get_id(args[3])}", :type => args[1], :data => args[4] } }
          when :create_unique_relationship
            {:method => "POST", :to => "/index/relationship/#{args[1]}?unique", :body => {:key => args[2], :value => args[3], :type => args[4], :start => (args[5].is_a?(String) && args[5].start_with?("{") ? "" : "/node/") + "#{get_id(args[5])}", :end=> (args[6].is_a?(String) && args[6].start_with?("{") ? "" : "/node/") + "#{get_id(args[6])}"} }
          when :delete_relationship
            {:method => "DELETE", :to => "/relationship/#{get_id(args[1])}"}
          when :set_relationship_property
            {:method => "PUT", :to => "/relationship/#{get_id(args[1])}/properties/#{args[2].keys.first}", :body => args[2].values.first}
          when :reset_relationship_properties
            {:method => "PUT", :to => (args[1].is_a?(String) && args[1].start_with?("{") ? "" : "/relationship/") + "#{get_id(args[1])}/properties", :body => args[2]}
          when :add_node_to_index
            {:method => "POST", :to => "/index/node/#{args[1]}", :body => {:uri => (args[4].is_a?(String) && args[4].start_with?("{") ? "" : "/node/") + "#{get_id(args[4])}", :key => args[2], :value => args[3] } }
          when :add_relationship_to_index
            {:method => "POST", :to => "/index/relationship/#{args[1]}", :body => {:uri => (args[4].is_a?(String) && args[4].start_with?("{") ? "" : "/relationship/") + "#{get_id(args[4])}", :key => args[2], :value => args[3] } }
          when :get_node_index
            {:method => "GET", :to => "/index/node/#{args[1]}/#{args[2]}/#{args[3]}"}
          when :get_relationship_index
            {:method => "GET", :to => "/index/relationship/#{args[1]}/#{args[2]}/#{args[3]}"}
          when :get_node_relationships
            {:method => "GET", :to => "/node/#{get_id(args[1])}/relationships/#{args[2] || 'all'}"}
          when :execute_script
            {:method => "POST", :to => @connection.gremlin_path, :body => {:script => args[1], :params => args[2]}}
          when :execute_query
            if args[2]
              {:method => "POST", :to => @connection.cypher_path, :body => {:query => args[1], :params => args[2]}}
            else
              {:method => "POST", :to => @connection.cypher_path, :body => {:query => args[1]}}
            end
          when :remove_node_from_index
            case args.size
              when 5 then {:method => "DELETE", :to => "/index/node/#{args[1]}/#{args[2]}/#{args[3]}/#{get_id(args[4])}" }
              when 4 then {:method => "DELETE", :to => "/index/node/#{args[1]}/#{args[2]}/#{get_id(args[3])}" } 
              when 3 then {:method => "DELETE", :to => "/index/node/#{args[1]}/#{get_id(args[2])}" } 
            end
          when :remove_relationship_from_index
           case args.size
             when 5 then {:method => "DELETE", :to => "/index/relationship/#{args[1]}/#{args[2]}/#{args[3]}/#{get_id(args[4])}" }
             when 4 then {:method => "DELETE", :to => "/index/relationship/#{args[1]}/#{args[2]}/#{get_id(args[3])}" }
             when 3 then {:method => "DELETE", :to => "/index/relationship/#{args[1]}/#{get_id(args[2])}" }
           end
          when :delete_node
            {:method => "DELETE", :to => "/node/#{get_id(args[1])}"}
          else
            raise "Unknown option #{args[0]}"
        end
      end

    end
  end
end
