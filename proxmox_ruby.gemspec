# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'proxmox_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "proxmox_ruby"
  spec.version       = ProxmoxRuby::VERSION
  spec.authors       = ["Rory McKinley"]
  spec.email         = ["rory.mckinley@hetzner.co.za"]
  spec.description   = %q{A gem to interact with the proxmox api}
  spec.summary       = %q{A gem to interact with the proxmox api}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.8.7"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.13.0"
end
