# frozen_string_literal: true

module Apigatewayv2Rack
  module Middlewares
    # Apigatewayv2Rack::Middlewares::CloudfrontXff transforms cloudfront-viewer-address to x-forwarded-for value.
    # It is recommended to use with Apigatewayv2Rack::Middlewares::CloudfrontVerify.
    class CloudfrontXff
      # When +replace_remote_addr_with+ is set, REMOTE_ADDR will be replaced with given value; this
      # allows Rack::Request#ip to respect xff on its default ip_filter. Default to 127.0.0.1.
      def initialize(app, replace_remote_addr_with: '127.0.0.1')
        @app = app
        @replace_remote_addr_with = replace_remote_addr_with
      end

      V6_REGEXP = /^([a-f0-9:]+):(\d+)$/

      def call(env)
        viewer = env['HTTP_CLOUDFRONT_VIEWER_ADDRESS']
        if viewer
          addr,port = if viewer.include?('.')
            viewer.split(?:, 2)
          else
            viewer.downcase.match(V6_REGEXP)&.to_a[1,2]
          end

          if addr && port
            env['HTTP_X_APIGATEWAYV2RACK_ORIG_X_FORWARDED_FOR'] = env['HTTP_X_FORWARDED_FOR'] if env['HTTP_X_FORWARDED_FOR']
            env['HTTP_X_APIGATEWAYV2RACK_ORIG_X_FORWARDED_PORT'] = env['HTTP_X_FORWARDED_PORT'] if env['HTTP_X_FORWARDED_PORT']
            env['HTTP_X_FORWARDED_FOR'] = addr
            env['HTTP_X_FORWARDED_PORT'] = port

            if @replace_remote_addr_with
              env['HTTP_X_APIGATEWAYV2RACK_ORIG_REMOTE_ADDR'] = env['REMOTE_ADDR'] if env['REMOTE_ADDR']
              env['REMOTE_ADDR'] = @replace_remote_addr_with
            end
          end
        end

        @app.call(env)
      end
    end
  end
end
