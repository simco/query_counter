$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "query_counter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "query_counter"
  s.version     = QueryCounter::VERSION
  s.authors     = ["Cedric Boulanger", "SIMCO Technologies"]
  s.email       = ["cboulanger@simcotechnologies.com"]
  s.homepage    = "http://www.simcotechnologies.com"
  s.summary     = "Add mysql query counters"
  s.description = "Once activated, all mysql queries will be counted"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "mysql2"
end
