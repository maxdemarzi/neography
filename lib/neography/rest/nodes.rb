module Neography
  class Rest
    module Nodes
      include Neography::Rest::Helpers

      def get_node(id)
        @connection.get("/node/%{id}" % {:id => get_id(id)})
      end

      def get_nodes(*nodes)
        gotten_nodes = []
        Array(nodes).flatten.each do |node|
          gotten_nodes << get_node(node)
        end
        gotten_nodes
      end

      def get_root
        root_node = @connection.get('/')["reference_node"]
        @connection.get("/node/%{id}" % {:id => get_id(root_node)})
      end

      def create_node(*args)
        if args[0].respond_to?(:each_pair) && args[0]
          create_node_with_attributes(args[0])
        else
          create_empty_node
        end
      end

      def create_node_with_attributes(attributes)
        options = {
          :body => attributes.delete_if { |k, v| v.nil? }.to_json,
          :headers => json_content_type
        }
        @connection.post("/node", options)
      end

      def create_empty_node
        @connection.post("/node")
      end

      def delete_node(id)
        @connection.delete("/node/%{id}" % {:id => get_id(id)})
      end

      def create_nodes(nodes)
        nodes = Array.new(nodes) if nodes.kind_of? Fixnum
        created_nodes = []
        nodes.each do |node|
          created_nodes << create_node(node)
        end
        created_nodes
      end

      def create_nodes_threaded(nodes)
        nodes = Array.new(nodes) if nodes.kind_of? Fixnum

        node_queue = Queue.new
        thread_pool = []
        responses = Queue.new

        nodes.each do |node|
          node_queue.push node
        end

        [nodes.size, @connection.max_threads].min.times do
          thread_pool << Thread.new do
            until node_queue.empty? do
              node = node_queue.pop
              if node.respond_to?(:each_pair)
                responses.push( @connection.post("/node", {
                  :body => node.to_json,
                  :headers => json_content_type
                } ) )
              else
                responses.push( @connection.post("/node") )
              end
            end
            self.join
          end
        end

        created_nodes = []

        while created_nodes.size < nodes.size 
          created_nodes << responses.pop
        end
        created_nodes
      end

    end
  end
end
