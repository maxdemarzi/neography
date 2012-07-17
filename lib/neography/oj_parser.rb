class OjParser < HTTParty::Parser
  Oj.default_options = { :mode => :strict }
  
  protected 
    def json
      Oj.load(body)
    end
end