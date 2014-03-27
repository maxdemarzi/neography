module Neography
  class Rest
    module Transactions
      include Neography::Rest::Helpers
    
      def begin_transaction(statements = [], commit = "")
        options = {
          :body => (
            convert_cypher(statements)
          ).to_json,
          :headers => json_content_type
        }
        @connection.post("/transaction" + commit, options)
      end

      def in_transaction(tx, statements = [])
        options = {
          :body => (
            convert_cypher(statements)
          ).to_json,
          :headers => json_content_type
        }
        @connection.post("/transaction/%{id}" % {:id => get_tx_id(tx)}, options)
      end
      
      def keep_transaction(tx)
        in_transaction(tx)
      end

      def commit_transaction(tx, statements = [])
        if (tx.is_a?(Hash) || tx.is_a?(Integer))
          options = {
            :body => (
              convert_cypher(statements)
            ).to_json,
            :headers => json_content_type
          }
          @connection.post("/transaction/%{id}/commit" %  {:id => get_tx_id(tx)}, options)
        else
          begin_transaction(tx, "/commit")
        end
      end
      
      def rollback_transaction(tx)
        @connection.delete("/transaction/%{id}" % {:id => get_tx_id(tx)})
      end

      private
      
      def get_tx_id(tx)
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
          case 
            when query && parameters && statement.is_a?(Array)
              then
                array << {:statement => query, :parameters => parameters, :resultDataContents => statement }
                query = nil
                parameters = nil        
            when query && parameters && statement.is_a?(String)
              then
                array << {:statement => query, :parameters => parameters}
                query = statement
                parameters = nil                 
            when query && statement.is_a?(Hash)
              then
                parameters = statement            
            when query && statement.is_a?(Array)
              then
                array << {:statement => query, :resultDataContents => statement }
                query = nil
                parameters = nil                       
            else
              query = statement
          end

        end
        
        if query && parameters
          array << {:statement => query, :parameters => parameters}
          query = nil
        end
        
        if query
          array << {:statement => query}
        end
        
        { :statements => array }
      end

    end
  end
end
