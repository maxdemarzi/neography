module Neography
  module Property


    def [](key)
      return unless respond_to?(key)
      @table[key]
    end

    def []=(key, value)
      k = key.to_s
      if value.nil?
        if self.is_a? Neography::Node
          neo_server.remove_node_properties(self.neo_id, [key])
          @table[key] = nil
        else
          neo_server.remove_relationship_properties(self.neo_id, [key])
          @table[key] = nil
        end
      else
        if self.is_a? Neography::Node
          neo_server.set_node_properties(self.neo_id, {k => value})
        else
          neo_server.set_relationship_properties(self.neo_id, {k => value})
        end
       
        new_ostruct_member(k) unless self.respond_to?(key)

      end
    end


  def new_ostruct_member(name)
    name = name.to_sym
    unless self.respond_to?(name)
      meta = class << self; self; end
      meta.send(:define_method, name) { @table[name] }
      meta.send(:define_method, "#{name}=") do |x| 
        @table[name] = x 
        self[name.to_sym] = x        
      end
    end
  end


  def self.method_missing(method_sym, *arguments, &block)
    if (method_sym.to_s =~ /$=/) != nil
      new_ostruct_member(method_sym.to_s.chomp("="))
    else
      super
    end
  end

  end
end