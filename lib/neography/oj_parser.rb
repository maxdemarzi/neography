class OjParser < HTTParty::Parser
 
  protected 
    def json
      #Oj::Doc.parse(body)
      Oj.load(body)
    end
end