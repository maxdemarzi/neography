module Neography
  class Rest
    class Constraints
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :base,       "/schema/constraint/"
      add_path :label,      "/schema/constraint/:label"            
      add_path :uniqueness, "/schema/constraint/:label/uniqueness/"
      add_path :unique,     "/schema/constraint/:label/uniqueness/:property"
      
      def initialize(connection)
        @connection = connection
      end

      def drop(label, property)
        @connection.delete(unique_path(:label => label, :property => property))
      end

      def list
        @connection.get(base_path)
      end

      def get(label)
        @connection.get(label_path(:label => label))
      end

      def get_uniqueness(label)
        @connection.get(uniqueness_path(:label => label))
      end

      def get_unique(label, property)
        @connection.get(unique_path(:label => label, :property => property))
      end

      def create_unique(label, property)
        options = {
          :body => {
            :property_keys => [property]
          }.to_json,
          :headers => json_content_type
        }
        @connection.post(uniqueness_path(:label => label), options)
      end

    end
  end
end
