module Neography
  class Config

    attr_accessor :protocol, :server, :port, :directory,
      :cypher_path, :gremlin_path,
      :log_file, :log_enabled, :logger, :slow_log_threshold,
      :max_threads,
      :authentication, :username, :password,
      :parser, :max_execution_time,
      :proxy, :http_send_timeout, :http_receive_timeout,
      :persistent

    def initialize
      set_defaults
    end

    def to_hash
      {
        :protocol              => @protocol,
        :server                => @server,
        :port                  => @port,
        :directory             => @directory,
        :cypher_path           => @cypher_path,
        :gremlin_path          => @gremlin_path,
        :log_file              => @log_file,
        :log_enabled           => @log_enabled,
        :logger                => @logger,
        :slow_log_threshold    => @slow_log_threshold,
        :max_threads           => @max_threads,
        :authentication        => @authentication,
        :username              => @username,
        :password              => @password,
        :parser                => @parser,
        :max_execution_time    => @max_execution_time,
        :proxy                 => @proxy,
        :http_send_timeout     => @http_send_timeout,
        :http_receive_timeout  => @http_receive_timeout,
        :persistent            => @persistent
      }
    end

    private

    def set_defaults
      @protocol             = "http"
      @server               = "localhost"
      @port                 = 7474
      @directory            = ""
      @cypher_path          = "/cypher"
      @gremlin_path         = "/ext/GremlinPlugin/graphdb/execute_script"
      @log_file             = "neography.log"
      @log_enabled          = false
      @slow_log_threshold   = 0
      @max_threads          = 20
      @authentication       = nil
      @username             = nil
      @password             = nil
      @parser               = MultiJsonParser
      @max_execution_time   = 6000
      @proxy                = nil
      @http_send_timeout    = 1200
      @http_receive_timeout = 1200
      @persistent           = true
    end
  end
end
