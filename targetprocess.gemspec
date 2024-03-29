# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'targetprocess/version'

Gem::Specification.new do |spec|
  spec.name          = "targetprocess"
  spec.version       = Targetprocess::VERSION
  spec.authors       = ["John Gray"]
  spec.email         = ["wopr42@gmail.com"]

  spec.summary       = %q{CLI and Ruby bindings for Targetprocess}
  spec.description   = %q{CLI and Ruby bindings for use with the Targetprocess Rest API v1}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'gli'
  spec.add_dependency 'httparty'
  spec.add_dependency 'terminal-table'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
