module Neography
  class Rest
    module NodePaths
      include Neography::Rest::Helpers
    
      def get_path(from, to, relationships, depth = 1, algorithm = "shortestPath")
        options = path_options(to, relationships, depth, algorithm)
        @connection.post("/node/%{id}/path" % {:id => get_id(from)}, options) || {}
      end

      def get_paths(from, to, relationships, depth = 1, algorithm = "allPaths")
        options = path_options(to, relationships, depth, algorithm)
        @connection.post("/node/%{id}/paths" % {:id => get_id(from)}, options) || []
      end

      def get_shortest_weighted_path(from, to, relationships, weight_attribute = "weight", depth = 1, algorithm = "dijkstra")
        options = path_options(to, relationships, depth, algorithm, { :cost_property => weight_attribute })
        @connection.post("/node/%{id}/paths" % {:id => get_id(from)}, options) || {}
      end

      private

      def get_algorithm(algorithm)
        case algorithm
          when :shortest, "shortest", :shortestPath, "shortestPath", :short, "short"
            "shortestPath"
          when :allSimplePaths, "allSimplePaths", :simple, "simple"
            "allSimplePaths"
          when :dijkstra, "dijkstra"
            "dijkstra"
          else
            "allPaths"
        end
      end

      def path_options(to, relationships, depth, algorithm, extra_body = {})
        options = { :body => {
            "to"            => @connection.configuration + "/node/#{get_id(to)}",
            "relationships" => relationships,
            "max_depth"     => depth,
            "algorithm"     => get_algorithm(algorithm)
          }.merge(extra_body).to_json,
          :headers => json_content_type
        }
      end

    end
  end
end
