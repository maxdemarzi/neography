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
      config = merge_configuration(options)
      save_local_configuration(config)
    end

    def configure(protocol, server, port, directory)
      @protocol = protocol
      @server = server
      @port = port
      @directory = directory
    end

    def configuration
      "#{@protocol}#{@server}:#{@port}#{@directory}/db/data"
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

    def merge_configuration(options)
      options = parse_string_options(options) unless options.is_a? Hash
      config = Neography.configuration.to_hash
      config.merge(options)
    end

    def save_local_configuration(config)
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
      if config[:authentication]
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
      when 400...500
        handle_4xx_response(code, body)
        nil
      end
    end

    def handle_4xx_response(code, body)
      parsed_body = JSON.parse(body)
      message = parsed_body["message"]
      stacktrace = parsed_body["stacktrace"]

      @logger.error "#{code} error: #{body}" if @log_enabled

      case code
      when 400, 404
        case parsed_body["exception"]
        when /SyntaxException/               ; raise SyntaxException.new(message, code, stacktrace)
        when /this is not a query/           ; raise SyntaxException.new(message, code, stacktrace)
        when /PropertyValueException/        ; raise PropertyValueException.new(message, code, stacktrace)
        when /BadInputException/             ; raise BadInputException.new(message, code, stacktrace)
        when /NodeNotFoundException/         ; raise NodeNotFoundException.new(message, code, stacktrace)
        when /NoSuchPropertyException/       ; raise NoSuchPropertyException.new(message, code, stacktrace)
        when /RelationshipNotFoundException/ ; raise RelationshipNotFoundException.new(message, code, stacktrace)
        when /NotFoundException/             ; raise NotFoundException.new(message, code, stacktrace)
        else
          raise NeographyError.new(message, code, stacktrace)
        end
      when 401
        raise UnauthorizedError.new(message, code, stacktrace)
      when 409
        raise OperationFailureException.new(message, code, stacktrace)
      else
        raise NeographyError.new(message, code, stacktrace)
      end
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
