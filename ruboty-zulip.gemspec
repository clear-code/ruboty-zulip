lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruboty/zulip/version'

Gem::Specification.new do |spec|
  spec.name          = "ruboty-zulip"
  spec.version       = Ruboty::Zulip::VERSION
  spec.authors       = ["okkez"]
  spec.email         = ["okkez000@gmail.com"]

  spec.summary       = "Zulip adapter for Ruboty."
  spec.description   = "Zulip adapter for Ruboty."
  spec.homepage      = "https://github.com/okkez/ruboty-zulip"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ruboty", ">= 1.3.0"
  spec.add_dependency "zulip-client"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
end
