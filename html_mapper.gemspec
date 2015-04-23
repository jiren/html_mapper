# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'html_mapper/version'

Gem::Specification.new do |spec|
  spec.name          = "html_mapper"
  spec.version       = HtmlMapper::VERSION
  spec.authors       = ["Jiren"]
  spec.email         = ["jirenpatel@gmail.com"]

  if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{HTML to ruby object or hash}
  spec.description   = %q{Parse html and map to ruby object or hash}
  spec.homepage      = "https://github.com/jiren/html_mapper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|examples|tasks)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.9.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'nokogiri', '>= 1.5.5'
  spec.add_dependency 'rest-client'
end
