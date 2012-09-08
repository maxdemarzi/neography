module Neography
  class Rest
    module Paths

      def self.included(mod)
        mod.send :extend, ClassMethods
      end

      def build_path(path, attributes)
        path.gsub(/:([\w_]*)/) do
          encode(attributes[$1.to_sym].to_s)
        end
      end

      def encode(value)
        URI.encode(value).gsub("/","%2F")
      end

      module ClassMethods
        def add_path(key, path)
          define_method :"#{key}_path" do |*attributes|
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
