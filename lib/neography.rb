def find_and_require_user_defined_code
  extensions_path = ENV['neography_extensions'] || "~/.neography"
  extensions_path = File.expand_path(extensions_path)
  if File.exists?(extensions_path)
    Dir.open extensions_path do |dir|
      dir.entries.each do |file|
        if file.split('.').size > 1 && file.split('.').last == 'rb'
          extension = File.join(File.expand_path(extensions_path), file) 
          require(extension) && puts("Loaded Extension: #{extension}")
        end
      end
    end
  else
    puts "No Extensions Found: #{extensions_path}"
  end
end

def evaluate_response(response)
  logger = Logger.new('log/neography.log')

  code = response.code
  body = response.body

  case code 
    when 200 
      logger.debug "OK" 
    when 201
      logger.debug "OK, created" 
    when 204  
      logger.debug "OK, no content returned" 
    when 400
      logger.error "Invalid data sent"
    when 404
      logger.error "#{body}"
  end

end

require 'httparty'
require 'json'
require 'logger'
#require 'net-http-spy'

#Net::HTTP.http_logger_options = {:verbose => true}
#Net::HTTP.http_logger_options = {:body => true}

require 'neography/neo'
require 'neography/node'


find_and_require_user_defined_code
