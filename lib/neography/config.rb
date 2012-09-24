module Neography
  class Config

    attr_accessor :protocol, :server, :port, :directory,
      :cypher_path, :gremlin_path,
      :log_file, :log_enabled,
      :max_threads,
      :authentication, :username, :password,
      :parser

    def initialize
      set_defaults
    end

    def to_hash
      {
        :protocol       => @protocol,
        :server         => @server,
        :port           => @port,
        :directory      => @directory,
        :cypher_path    => @cypher_path,
        :gremlin_path   => @gremlin_path,
        :log_file       => @log_file,
        :log_enabled    => @log_enabled,
        :max_threads    => @max_threads,
        :authentication => @authentication,
        :username       => @username,
        :password       => @password,
        :parser         => @parser
      }
    end

    private

    def set_defaults
      @protocol       = "http://"
      @server         = "localhost"
      @port           = 7474
      @directory      = ""
      @cypher_path    = "/cypher"
      @gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
      @log_file       = "neography.log"
      @log_enabled    = false
      @max_threads    = 20
      @authentication = nil
      @username       = nil
      @password       = nil
      @parser         = {:parser => MultiJsonParser}
    end

  end
end
