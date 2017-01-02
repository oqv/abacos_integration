#encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "abacos_integration/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "abacos_integration"
  s.version     = AbacosIntegration::VERSION
  s.authors     = ["Victor Alencar", "Rene Schneider"]
  s.email       = ["victor.alencar@oqvestir.com.br", "renews@oqvestir.com.br"]
  s.homepage    = "https://github.com/oqv/abacos_integration"
  s.summary     = "Gem para consumo do ERP Abacos."
  s.description = "Gem para consumo do ERP Abacos através de seus WebServices listados em sua documentação original."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"

  s.add_dependency "sinatra"
  s.add_dependency "tilt", "~> 1.4.1"
  s.add_dependency "tilt-jbuilder"
  s.add_dependency "endpoint_base"
  # s.add_dependency "honeybadger"
  s.add_dependency "savon"
  s.add_dependency "business_time"

  s.add_development_dependency "sqlite3"
end
