module Neography
  class Connection

    USER_AGENT = "Neography/#{Neography::VERSION}"

    attr_accessor :protocol, :server, :port, :directory,
      :cypher_path, :gremlin_path,
      :log_file, :log_enabled, :logger,
      :max_threads,
      :authentication, :username, :password,
      :parser

    def initialize(options = ENV['NEO4J_URL'] || {})
      options = parse_string_options(options) unless options.is_a? Hash
      config = initial_configuration
      config.merge!(options)

      @protocol       = config[:protocol]
      @server         = config[:server]
      @port           = config[:port]
      @directory      = config[:directory]
      @cypher_path    = config[:cypher_path]
      @gremlin_path   = config[:gremlin_path]
      @log_file       = config[:log_file]
      @log_enabled    = config[:log_enabled]
      @max_threads    = config[:max_threads]
      @parser         = config[:parser]
      @user_agent     = { "User-Agent" => USER_AGENT }

      @authentication = {}

      unless config[:authentication].empty?
        @authentication = {
          "#{config[:authentication]}_auth".to_sym => {
            :username => config[:username],
            :password => config[:password]
          }
        }
      end

      if @log_enabled
        @logger = Logger.new(@log_file)
      end
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

    private

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

    def initial_configuration
      {
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
    end

    def parse_string_options(options)
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
      options
    end

  end
end
