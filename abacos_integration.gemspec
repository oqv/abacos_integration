$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "abacos_integration/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "abacos_integration"
  s.version     = AbacosIntegration::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of AbacosIntegration."
  s.description = "TODO: Description of AbacosIntegration."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_dependency "sinatra"
  s.add_dependency "tilt", "~> 1.4.1"
  s.add_dependency "tilt-jbuilder"
  s.add_dependency "endpoint_base"
  # s.add_dependency "honeybadger"
  s.add_dependency "savon"
  
  s.add_development_dependency "sqlite3"
end
