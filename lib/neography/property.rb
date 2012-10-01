module Neography
  module Property

    def [](key)
      key = key.to_sym
      return unless respond_to?(key)
      @table[key]
    end

    def []=(key, value)
      key = key.to_sym
      k_str = key.to_s
      if value.nil?
        if self.is_a? Neography::Node
          neo_server.remove_node_properties(self.neo_id, [k_str])
        else
          neo_server.remove_relationship_properties(self.neo_id, [k_str])
        end
      else
        if self.is_a? Neography::Node
          neo_server.set_node_properties(self.neo_id, {k_str => value})
        else
          neo_server.set_relationship_properties(self.neo_id, {k_str => value})
        end
        new_ostruct_member(key) unless self.respond_to?(key)
      end
      @table[key] = value
    end

    def new_ostruct_member(name)
      name = name.to_sym
      unless self.respond_to?(name)
        meta = class << self; self; end
        meta.send(:define_method, name) { @table[name] }
        meta.send(:define_method, "#{name}=") do |value|
          @table[name] = value
          self[name.to_sym] = value
        end
      end
      name
    end

    def method_missing(method_sym, *arguments, &block)
      if (method_sym.to_s =~ /=$/) != nil
        new_ostruct_member(method_sym.to_s.chomp("="))

        # We just defined the getter/setter above, but we haven't actually
        # applied them yet.
        self.send(method_sym, *arguments)
      else
        super
      end
    end

    def attributes
      @table.keys
    end

  end
end
