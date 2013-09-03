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
  s.description = "A Ruby wrapper to the Neo4j Rest API see http://docs.neo4j.org/chunked/stable/rest-api.html for more details."

  s.rubyforge_project = "neography"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", ">= 2.11"
  s.add_development_dependency "net-http-spy", "0.2.1"
  s.add_development_dependency "rake", ">= 0.8.7"
  s.add_development_dependency "coveralls"
  s.add_dependency "httpclient", ">= 2.3.3"
  s.add_dependency "rake", ">= 0.8.7"
  s.add_dependency "json", ">= 1.7.7"
  s.add_dependency "os", ">= 0.9.6"
  s.add_dependency "rubyzip", "~> 1.0.0"
  s.add_dependency "multi_json", ">= 1.3.2"
end
