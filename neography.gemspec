# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "neography/version"

Gem::Specification.new do |s|
  s.name        = "neography"
  s.version     = Neography::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Max De Marzi"
  s.email       = "maxdemarzi@gmail.com"
  s.homepage    = "http://rubygems.org/gems/neography"
  s.summary     = "ruby wrapper to Neo4j Rest API"
  s.description = "A Ruby wrapper to the Neo4j Rest API see http://components.neo4j.org/neo4j-rest/ for more details."

  s.rubyforge_project = "neography"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~> 2.0.0.beta.22"
  s.add_development_dependency "net-http-spy", "0.2.1"
  s.add_development_dependency "fakeweb", "~> 1.3.0"
  s.add_development_dependency "rake", "~> 0.8.7"
  s.add_dependency "httparty", "~> 0.7.3"
  s.add_dependency "json"
end
