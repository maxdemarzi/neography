module Neography
  class Config 
    class << self; attr_accessor :protocol, :server, :port, :log_file, :log_enabled, :logger, :max_threads end

    @protocol = 'http://'
    @server = 'localhost'
    @port = 7474 
    @log_file = 'neography.log'
    @log_enabled = false
    @logger = Logger.new(@log_file) if @log_enabled
    @max_threads = 20

  end
end