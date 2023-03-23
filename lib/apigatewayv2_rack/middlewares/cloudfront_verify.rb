# frozen_string_literal: true
require 'rack/utils'

module Apigatewayv2Rack
  module Middlewares
    # Compare X-Origin-Verify header matches the expected value and otherwise returns 403.
    # This is useful to use with CloudFront's origin custom request header to protect from direct access to function.
    #
    # See also: https://www.wellarchitectedlabs.com/security/300_labs/300_multilayered_api_security_with_cognito_and_waf/3_prevent_requests_from_accessing_api_directly/
    class CloudfrontVerify
      # +value+ is an expected string value of x-origin-verify.
      def initialize(app, value)
        @app = app
        @value = value
      end

      def env_name
        'HTTP_X_ORIGIN_VERIFY'
      end

      def call(env)
        given = env[env_name]

        unless given && Rack::Utils.secure_compare(given, @value)
          env['rack.logger']&.warn("#{self.class.name} protected unwanted access from #{env['REMOTE_ADDR'].inspect}")
          return [401, {'Content-Type' => 'text/plain'}, ['Unauthorized']]
        end

        @app.call(env)
      end
    end
  end
end
