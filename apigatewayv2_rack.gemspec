# frozen_string_literal: true

require_relative "lib/apigatewayv2_rack/version"

Gem::Specification.new do |spec|
  spec.name = "apigatewayv2_rack"
  spec.version = Apigatewayv2Rack::VERSION
  spec.authors = ["Sorah Fukumori"]
  spec.email = ["her@sorah.jp"]

  spec.summary = "handle AWS Lambda API Gateway V2 or ALB (ELBv2) lambda request event with Rack application"
  spec.homepage = "https://github.com/sorah/apigatewayv2_rack"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sorah/apigatewayv2_rack"
  spec.metadata["changelog_uri"] = "https://github.com/sorah/apigatewayv2_rack/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'rack'
  spec.add_dependency 'base64'
  spec.add_dependency 'stringio'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
