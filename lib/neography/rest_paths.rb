module Neography
  class Rest
    module Paths

      def self.included(mod)
        mod.send :extend, ClassMethods
      end

      def build_path(path, attributes)
        path.gsub(/:([\w_]*)/) do
          attributes[$1.to_sym].to_s
        end
      end

      module ClassMethods
        def add_path(key, path)
          define_method key do |*attributes|
            if attributes.any?
              build_path(path, *attributes)
            else
              path
            end
          end
        end
      end

    end
  end
end
