# frozen_string_literal: true

require_relative "apigatewayv2_rack/version"
require_relative "apigatewayv2_rack/error"
require_relative "apigatewayv2_rack/request"
require_relative "apigatewayv2_rack/response"

require_relative "apigatewayv2_rack/middlewares/cloudfront_xff"
require_relative "apigatewayv2_rack/middlewares/cloudfront_verify"

module Apigatewayv2Rack
  # Takes Rack +app+, Lambda +event+ and +context+ of API Gateway V2 event and
  # returns a HTTP response from +app+ as API Gateway V2 Lambda event format.
  #
  # When block is given, converted Rack env will be passed to make some final
  # modification before passing it to an +app+.
  def self.handle_request(app:, event:, context:, request_options: {}, &block)
    req = Request.new(event, context, **request_options)
    env = req.to_h
    block&.call(env, req)
    status, headers, body = app.call(env)
    Response.new(status: status, headers: headers, body: body, elb: req.elb?, multivalued: req.multivalued?).as_json
  end

  module Handler
    attr_reader :app
    attr_reader :block
    def handle(event:, context:, &givenblock)
      b = givenblock || @block
      Apigatewayv2Rack.handle_request(event: event, context: context, app: @app, &b)
    end
  end

  def self.generate_handler(app, &block)
    m = Module.new
    m.extend(Handler)
    m.instance_variable_set(:@app, app)
    m.instance_variable_set(:@block, block)
    m
  end

  def self.handler_from_rack_config_file(path = './config.ru', &block)
    require 'rack'
    require 'rack/builder'
    app = if Rack.release[0] == '2'
      Rack::Builder.load_file(path, {})[0]
    else
      Rack::Builder.load_file(path)
    end
    generate_handler(app, &block)
  end
end
