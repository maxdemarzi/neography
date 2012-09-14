module Neography
  class Rest
    module Delegation

      def def_rest_delegations(options)
        options.each do |target_class, delegations|
          delegations.each do |from_method, to_method|
            def_delegator target_class, to_method, from_method
          end
        end
      end

    end
  end
end
