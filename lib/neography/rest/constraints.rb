module Neography
  class Rest
    module Constraints
      include Neography::Rest::Helpers
    
      def drop_constraint(label, property)
        @connection.delete("/schema/constraint/%{label}/uniqueness/%{property}" % {:label => label, :property => property})
      end

      def get_constraints(label=nil)
        #if label.nil?
        #  @connection.get(base_path)          
        #else
          @connection.get("/schema/constraint/%{label}" % {:label => label})
        #end
      end

      def get_uniqueness(label)
        @connection.get("/schema/constraint/%{label}/uniqueness/" % {:label => label})
      end

      def get_unique_constraint(label, property)
        @connection.get("/schema/constraint/%{label}/uniqueness/%{property}" % {:label => label, :property => property})
      end

      def create_unique_constraint(label, property)
        options = {
          :body => {
            :property_keys => [property]
          }.to_json,
          :headers => json_content_type
        }
        @connection.post("/schema/constraint/%{label}/uniqueness/" % {:label => label}, options)
      end

    end
  end
end
