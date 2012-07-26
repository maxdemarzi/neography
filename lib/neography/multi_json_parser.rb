class MultiJsonParser < HTTParty::Parser

  protected

    def json
      MultiJson.load(body)
    end

end
