module Neography
  class Rest
    class Nodes
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :index,  "/node"
      add_path :base,   "/node/:id"

      def initialize(connection)
        @connection = connection
      end

      def get(id)
        @connection.get(base_path(:id => get_id(id)))
      end

      def get_each(*nodes)
        gotten_nodes = []
        Array(nodes).flatten.each do |node|
          gotten_nodes << get(node)
        end
        gotten_nodes
      end

      def root
        root_node = @connection.get('/')["reference_node"]
        @connection.get(base_path(:id => get_id(root_node)))
      end

      def create(*args)
        if args[0].respond_to?(:each_pair) && args[0]
          create_with_attributes(args[0])
        else
          create_empty
        end
      end

      def create_with_attributes(attributes)
        options = {
          :body => attributes.delete_if { |k, v| v.nil? }.to_json,
          :headers => json_content_type
        }
        @connection.post(index_path, options)
      end

      def create_empty
        @connection.post(index_path)
      end

      def delete(id)
        @connection.delete(base_path(:id => get_id(id)))
      end

      def create_multiple(nodes)
        nodes = Array.new(nodes) if nodes.kind_of? Fixnum
        created_nodes = []
        nodes.each do |node|
          created_nodes << create(node)
        end
        created_nodes
      end

      def create_multiple_threaded(nodes)
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
                responses.push( @connection.post(index_path, {
                  :body => node.to_json,
                  :headers => json_content_type
                } ) )
              else
                responses.push( @connection.post(index_path) )
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
