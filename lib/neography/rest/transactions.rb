module Neography
  class Rest
    class Transactions
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :base,   "/transaction"
      add_path :tx,    "/transaction/:id"
      add_path :commit, "/transaction/:id/commit"
      
      def initialize(connection)
        @connection = connection
      end

      def begin(statements = [], commit = "")
        options = {
          :body => (
            convert_cypher(statements)
          ).to_json,
          :headers => json_content_type
        }
        @connection.post(base_path + commit, options)
      end

      def add(tx, statements = [])
        options = {
          :body => (
            convert_cypher(statements)
          ).to_json,
          :headers => json_content_type
        }
        @connection.post(tx_path(:id => get_id(tx)), options)
      end

      def commit(tx, statements = [])
        options = {
          :body => (
            convert_cypher(statements)
          ).to_json,
          :headers => json_content_type
        }
        @connection.post(commit_path(:id => get_id(tx)), options)
      end
      
      def rollback(tx)
        @connection.delete(tx_path(:id => get_id(tx)))
      end

      private
      
      def get_id(tx)
        return tx if tx.is_a?(Integer)
        return tx.split("/")[-2] if tx.is_a?(String)
        return tx["commit"].split("/")[-2] if tx["commit"]
        raise NeographyError.new("Could not determine transaction id", nil, tx)
      end
      
      def convert_cypher(statements)
        array = []
        query = nil
        parameters = nil
        Array(statements).each do |statement|
          if query && parameters
            array << {:statement => query, :parameters => {:props => parameters}}
            query = statement
            parameters = nil            
          elsif query && statement.is_a?(String)
            array << {:statement => query}
            query = statement
            parameters = nil 
          elsif query && statement.is_a?(Hash)
            array << {:statement => query, :parameters => {:props => parameters}}
            query = nil
            parameters = nil            
          end
          query = statement
        end
        array << {:statement => query} if query
        { :statements => array }
      end
    end
  end
end
