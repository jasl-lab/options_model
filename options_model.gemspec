# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "options_model/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "options_model"
  s.version     = OptionsModel::VERSION
  s.authors     = ["jasl"]
  s.email       = ["jasl9187@hotmail.com"]
  s.homepage    = "https://github.com/jasl-lab/options_model"
  s.summary     = "Make easier to handle model which will be serialized in a real model."
  s.description = <<-DESC.strip
    An ActiveModel implementation that make easier to handle model which will be serialized in a real model.
  DESC

  s.license = "MIT"

  s.files   = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "activemodel", ">= 5", "< 9"
  s.add_dependency "activesupport", ">= 5", "< 9"
  s.add_dependency "psych", ">= 3.2"
end
