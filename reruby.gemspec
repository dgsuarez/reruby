lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reruby/version'

Gem::Specification.new do |spec|
  spec.name          = "reruby"
  spec.version       = Reruby::VERSION
  spec.authors       = ["Diego Guerra"]
  spec.email         = ["diego.guerra.suarez@gmail.com"]

  spec.summary       = 'Simple refactorings for Ruby'
  spec.homepage      = "https://github.com/dgsuarez/reruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "git"
  spec.add_dependency "parser"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "rubocop"
end
