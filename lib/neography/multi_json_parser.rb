class MultiJsonParser


    # I know this looks pretty ugly, but we have issues with Neo4j returning true, false,
    # plain numbers and plain strings, which is considered by some JSON libraries to be
    # invalid JSON, but some consider it perfectly fine.
    # This ugly hack deals with the problem.  Send me a Pull Request if you
    # come up with a nicer solution... please!
    #
    def self.json(body)
      begin
        MultiJson.load(body)
      rescue MultiJson::DecodeError, ArgumentError
        case
          when body == "true"
            true
          when body == "false"
            false
           when body.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
            Float(body)
          else
            body[1..-2]
        end

      end
    end

end
