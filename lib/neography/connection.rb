module Neography
  class Connection

    USER_AGENT = "Neography/#{Neography::VERSION}"

    attr_accessor :protocol, :server, :port, :directory,
      :cypher_path, :gremlin_path,
      :log_file, :log_enabled, :logger,
      :max_threads,
      :authentication, :username, :password,
      :parser

    def initialize(options=ENV['NEO4J_URL'] || {})
      init = {
        :protocol       => Neography::Config.protocol,
        :server         => Neography::Config.server,
        :port           => Neography::Config.port,
        :directory      => Neography::Config.directory,
        :cypher_path    => Neography::Config.cypher_path,
        :gremlin_path   => Neography::Config.gremlin_path,
        :log_file       => Neography::Config.log_file,
        :log_enabled    => Neography::Config.log_enabled,
        :max_threads    => Neography::Config.max_threads,
        :authentication => Neography::Config.authentication,
        :username       => Neography::Config.username,
        :password       => Neography::Config.password,
        :parser         => Neography::Config.parser
      }

      unless options.respond_to?(:each_pair)
        url = URI.parse(options)
        options = {
          :protocol  => url.scheme + "://",
          :server    => url.host,
          :port      => url.port,
          :directory => url.path,
          :username  => url.user,
          :password  => url.password
        }
        options[:authentication] = 'basic' unless url.user.nil?
      end

      init.merge!(options)

      @protocol       = init[:protocol]
      @server         = init[:server]
      @port           = init[:port]
      @directory      = init[:directory]
      @cypher_path    = init[:cypher_path]
      @gremlin_path   = init[:gremlin_path]
      @log_file       = init[:log_file]
      @log_enabled    = init[:log_enabled]
      @logger         = Logger.new(@log_file) if @log_enabled
      @max_threads    = init[:max_threads]
      @authentication = {}
      @authentication = {"#{init[:authentication]}_auth".to_sym => {:username => init[:username], :password => init[:password]}} unless init[:authentication].empty?
      @parser         = init[:parser]
      @user_agent     = {"User-Agent" => USER_AGENT}
    end

    def configure(protocol, server, port, directory)
      @protocol = protocol
      @server = server
      @port = port 
      @directory = directory
    end

    def configuration
      @protocol + @server + ':' + @port.to_s + @directory + "/db/data"
    end

    def merge_options(options)
      merged_options = options.merge!(@authentication).merge!(@parser)
      merged_options[:headers].merge!(@user_agent) if merged_options[:headers]
      merged_options
    end

    def get(path, options={})
      evaluate_response(HTTParty.get(configuration + path, merge_options(options)))
    end

    def post(path, options={})
      evaluate_response(HTTParty.post(configuration + path, merge_options(options)))
    end

    def put(path, options={})
      evaluate_response(HTTParty.put(configuration + path, merge_options(options)))
    end

    def delete(path, options={})
      evaluate_response(HTTParty.delete(configuration + path, merge_options(options)))
    end

    def evaluate_response(response)
      code = response.code
      body = response.body
      case code 
      when 200 
        @logger.debug "OK" if @log_enabled
        response.parsed_response
      when 201
        @logger.debug "OK, created #{body}" if @log_enabled
        response.parsed_response
      when 204  
        @logger.debug "OK, no content returned" if @log_enabled
        nil
      when 400
        @logger.error "Invalid data sent #{body}"  if @log_enabled
        nil
      when 404
        @logger.error "Not Found #{body}" if @log_enabled
        nil
      when 409
        @logger.error "Node could not be deleted (still has relationships?)" if @log_enabled
        nil
      end
    end

  end
end
