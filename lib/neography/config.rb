module Neography
  class Config 
    class << self; attr_accessor :protocol, :server, :port, :directory, :cypher_path, :gremlin_path, :log_file, :log_enabled, :logger, :max_threads, :authentication, :username, :password, :parser end

    @protocol       = 'http://'
    @server         = 'localhost'
    @port           = 7474 
    @directory      = ''
    @cypher_path    = '/cypher'
    @gremlin_path   = '/ext/GremlinPlugin/graphdb/execute_script'
    @log_file       = 'neography.log'
    @log_enabled    = false
    @logger         = Logger.new(@log_file) if @log_enabled
    @max_threads    = 20
    @authentication = {}
    @username       = nil
    @password       = nil
    @parser         = {:parser => CrackParser}
  end
end