lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec-api/requests/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-api-requests"
  spec.version       = RSpecApi::Requests::VERSION
  spec.authors       = ["claudiob"]
  spec.email         = ["claudiob@gmail.com"]
  spec.description   = %q{}
  spec.summary       = %q{}
  spec.homepage      = 'https://github.com/rspec-api/rspec-api-requests'
  spec.license       = 'MIT'

  spec.files         = Dir['{lib}/**/*'] + ['MIT-LICENSE', 'README.md']

  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.2'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.add_dependency 'rspec'
  spec.add_dependency 'rspec-api-expectations', '~> 0.7.1' # expect(200).to match_status(200)

  spec.add_dependency 'activesupport' # to .slice, etc
  spec.add_dependency 'faraday'   # to send remote HTTP requests
  spec.add_dependency 'faraday_middleware' # to encode JSON in POST

  # For development / Code coverage
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rack-test' # to test local apps
end