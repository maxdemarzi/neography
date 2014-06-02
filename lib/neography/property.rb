module Neography
  module Property

    def [](key)
      @table[key.to_sym]
    end

    def []=(key, value)
      key = key.to_sym
      k_str = key.to_s
      if value.nil?
        unless @table[key].nil?
          if node?
            neo_server.remove_node_properties(self.neo_id, [k_str])
          else
            neo_server.remove_relationship_properties(self.neo_id, [k_str])
          end
        end
        remove_ostruct_member(key)
      else
        if node?
          neo_server.set_node_properties(self.neo_id, {k_str => value})
        else
          neo_server.set_relationship_properties(self.neo_id, {k_str => value})
        end
        new_ostruct_member(key, value)
      end
    end

    # Set many properties at once and only issue one http
    # request and update the node/relationship instance on the fly.
    def reset_properties(hash)
      hash.each do |key, value|
        add_or_remove_ostruct_member(key, value)
      end
      if node?
        neo_server.reset_node_properties(self.neo_id, hash)
      else
        neo_server.reset_relationship_properties(self.neo_id, hash)
      end
    end

    def add_or_remove_ostruct_member(name, value)
      if value.nil?
        remove_ostruct_member(name)
      else
        new_ostruct_member(name, value)
      end
    end

    def new_ostruct_member(name, value)
      name = name.to_sym
      @table[name] = value
      unless self.respond_to?(name)
        meta = class << self; self; end
        meta.send(:define_method, name) { @table[name] }
        meta.send(:define_method, "#{name}=") do |new_value|
          self[name.to_sym] = new_value
        end
      end
      name
    end

    def remove_ostruct_member(name)
      @table.delete(name.to_sym)
      meta = class << self; self; end
      names = [name, "#{name}="].map(&:to_sym)
      names.each do |n|
        meta.send(:remove_method, n) if self.respond_to?(n)
      end
    end

    def method_missing(method_sym, *arguments, &block)
      if (method_sym.to_s =~ /=$/) != nil
        new_ostruct_member(method_sym.to_s.chomp("="), *arguments)

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

    def node?
      self.is_a?(Neography::Node)
    end

  end
end
