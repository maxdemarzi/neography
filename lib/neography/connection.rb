module Neography
  module WasCreated
  end
  class Connection
    USER_AGENT = "Neography/#{Neography::VERSION}"
    ACTIONS = ["get", "post", "put", "delete"]

    attr_reader :protocol, :server, :port, :directory,
      :cypher_path, :gremlin_path,
      :log_file, :log_enabled, :logger, :slow_log_threshold,
      :max_threads,
      :authentication, :username, :password,
      :parser, :client,
      :proxy, :http_send_timeout, :http_receive_timeout

    def initialize(options = {})
      config = merge_configuration(options)
      save_local_configuration(config)
      @client ||= Excon.new(config[:proxy] || "#{protocol}://#{@server}:#{@port}", 
                            :read_timeout => config[:http_receive_timeout],
                            :write_timeout => config[:http_send_timeout],
                            :persistent => config[:persistent],
                            :user =>  config[:username],
                            :password => config[:password])
      #authenticate
    end

    def configure(protocol, server, port, directory)
      @protocol = protocol
      @server = server
      @port = port
      @directory = directory
    end

    # Keeping backward compatability for folks who used "http://" syntax instead of "http"
    def protocol
      @protocol.sub("://","")
    end

    def configuration
      @configuration ||= "#{protocol}://#{@server}:#{@port}#{@directory}"
    end

    def merge_options(options)
      merged_options = options.merge!(@authentication)
      if merged_options[:headers]
        merged_options[:headers].merge!(@user_agent)
        merged_options[:headers].merge!('X-Stream' => true) unless merged_options[:headers].key?('X-Stream')
        merged_options[:headers].merge!(@max_execution_time)
      end
      merged_options
    end

    ACTIONS.each do |action|
      define_method(action) do |path, options = {}|
        # This ugly hack is required because internal Batch paths do not start with "/db/data"
        # if somebody has a cleaner solution... pull request please!
        partial_path = path.split("/") 
        if partial_path.size > 0
          partial_path = partial_path[1].split("?").first
        end
        reserved = ["node", "relationship", "transaction", "cypher", "propertykeys", "schema", "label", "labels", "batch", "index", "ext"]
        path = "/db/data" + path if reserved.include?(partial_path)
        query_body = options[:body]
        stream = ""
        headers = merge_options(options)[:headers]
        log path, query_body do
          req_params = {:method => action.to_sym, :path => path, :body => query_body, :headers => headers}
          is_streaming = headers && (headers['X-Stream'] == true)
          if is_streaming
            streamer = lambda { |chunk, _, _| stream += chunk }
            req_params.merge!({:persistent => false, :response_block => streamer,
                               :read_timeout => 100000000, :write_timeout => 100000000})
          end
          response = @client.request(req_params)
          evaluate_response(response, path, query_body, is_streaming, (partial_path == "batch"), stream)
        end
      end
    end

    def log(path, body)
      if @log_enabled
        start_time = Time.now
        response = yield
        time = ((Time.now - start_time) * 1000).round(2)
        @logger.info "[Neography::Query] #{path} #{body} [#{time}ms]" if time >= slow_log_threshold
        response
      else
        yield
      end
    end

    def authenticate(path = nil)
      unless @authentication.empty?
        auth_type = @authentication.keys.first
        @client.set_auth(
          path,
          @authentication[auth_type][:username],
          @authentication[auth_type][:password]
        )
        # Force http client to always send auth credentials without
        # waiting for WWW-Authenticate headers, thus saving one request
        # roundtrip for each URI. Only works for HTTP basic auth.
        @client.www_auth.basic_auth.challenge(configuration) if auth_type == 'basic_auth'
      end
    end

    private

    def merge_configuration(options)
      options = parse_string_options(options) unless options.is_a? Hash
      config = Neography.configuration.to_hash
      config.merge(options)
    end

    def save_local_configuration(config)
      @protocol           = config[:protocol]
      @server             = config[:server]
      @port               = config[:port]
      @directory          = config[:directory]
      @cypher_path        = config[:cypher_path]
      @gremlin_path       = config[:gremlin_path]
      @log_file           = config[:log_file]
      @log_enabled        = config[:log_enabled]
      @slow_log_threshold = config[:slow_log_threshold]
      @max_threads        = config[:max_threads]
      @parser             = config[:parser]
      @logger             = config[:logger]
      @proxy              = config[:proxy]

      @max_execution_time = { 'max-execution-time' => config[:max_execution_time] }
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
        @logger ||= Logger.new(@log_file)
      end
    end

    def evaluate_chunk_response(response, result)
      code = response.code
      return_result(code, result)
    end

    def evaluate_response(response, path, query_body, streaming, batching, stream = nil)
      code = response.status
      parsed = false
      if streaming && batching
        code, body, parsed = handle_batch(stream)
      elsif streaming
        body = (stream || '').force_encoding("UTF-8")
      else
        body = response.body.force_encoding("UTF-8")
      end
      return_result(response, code, body, parsed, path, query_body)
    end

    def handle_batch(stream)
      code = 200
      body = @parser.json(stream.force_encoding("UTF-8"))
      body.each do |result|
        if result["status"] >= 400
          code = result["status"]
          break
        end
      end
      return code, body, true
    end

    def return_result(response, code, body, parsed, path, query_body)
      case code
      when 200
        @logger.debug "OK #{body}" if @log_enabled
        parsed ? body : @parser.json(body)
      when 201
        @logger.debug "OK, created #{body}" if @log_enabled
        r = parsed ? body : @parser.json(body)
        r.extend(WasCreated)
        r
      when 204
        @logger.debug "OK, no content returned" if @log_enabled
        nil
      else
        handle_4xx_500_response(response, code, body, path, query_body)
        nil
      end
    end

    def handle_4xx_500_response(response, code, body, path, query_body)
      index = 0
      request = {:path => path, :body => query_body}
      if body.nil? or body == ""
        parsed_body = {"message" => "No error message returned from server.",
                       "stacktrace" => "No stacktrace returned from server." }
      elsif body.is_a? Hash
        parsed_body = body
      elsif body.is_a? Array
        body.each_with_index do |result, idx|
          if result["status"] >= 400
            index = idx
            parsed_body = result["body"] || result
            break
          end
        end
      else
        parsed_body = @parser.json(body)
      end

      message = parsed_body["message"]
      stacktrace = parsed_body["stacktrace"]

      @logger.error "#{response.data} error: #{body}" if @log_enabled
      raise_errors(code, parsed_body["exception"], message, stacktrace, request, index)
    end

    def raise_errors(code, exception, message, stacktrace, request, index)
      error = nil
      case code
        when 401
          error = UnauthorizedError
        when 409
          error = OperationFailureException
      end

      error ||= case exception
        when /SyntaxException/               ; SyntaxException
        when /this is not a query/           ; SyntaxException
        when /PropertyValueException/        ; PropertyValueException
        when /BadInputException/             ; BadInputException
        when /NodeNotFoundException/         ; NodeNotFoundException
        when /NoSuchPropertyException/       ; NoSuchPropertyException
        when /RelationshipNotFoundException/ ; RelationshipNotFoundException
        when /ParameterNotFoundException/    ; ParameterNotFoundException
        when /NotFoundException/             ; NotFoundException
        when /UniquePathNotUniqueException/  ; UniquePathNotUniqueException
        when /DeadlockDetectedException/     ; DeadlockDetectedException
        else
          NeographyError
      end

      raise error.new(message, code, stacktrace, request, index)
    end

    def parse_string_options(options)
      url = URI.parse(options)
      options = {
        :protocol  => url.scheme,
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
