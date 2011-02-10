module Neography
  class Config 
    class << self; attr_accessor :protocol, :server, :port, :directory, :log_file, :log_enabled, :logger, :max_threads, :authentication, :username, :password end

    @protocol = 'http://'
    @server = 'localhost'
    @port = 7474 
    @directory = ''
    @log_file = 'neography.log'
    @log_enabled = false
    @logger = Logger.new(@log_file) if @log_enabled
    @max_threads = 20
    @authentication = {}
    @username = nil
    @password = nil
  end
end