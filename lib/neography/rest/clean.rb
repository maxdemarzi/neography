module Neography
  class Rest
    module Clean
      include Neography::Rest::Helpers

      def clean_database(sanity_check = "not_really")
        if sanity_check == "yes_i_really_want_to_clean_the_database"
          @connection.delete("/cleandb/secret-key")
          true
        else
          false
        end          
      end

    end
  end
end
