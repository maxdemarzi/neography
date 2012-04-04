class CrackParser < HTTParty::Parser
 
  protected 
    def json
      Crack::JSON.parse(body)
    end
end