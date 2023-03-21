# frozen_string_literal: true

require_relative "apigatewayv2_rack/version"
require_relative "apigatewayv2_rack/error"
require_relative "apigatewayv2_rack/request"
require_relative "apigatewayv2_rack/response"

module Apigatewayv2Rack
  # Takes Rack +app+, Lambda +event+ and +context+ of API Gateway V2 event and
  # returns a HTTP response from +app+ as API Gateway V2 Lambda event format.
  def self.handle_request(app:, event:, context:, request_options: {})
    req = Request.new(event, context, **request_options)
    status, headers, body = app.call(req.to_h)
    Response.new(status: status, headers: headers, body: body, elb: req.elb?, multivalued: req.multivalued?).as_json
  end

  module Handler
    attr_reader :app 
    def handle(event:, context:)
      Apigatewayv2Rack.handle_request(event: event, context: context, app: @app)
    end
  end

  def self.generate_handler(app)
    m = Module.new
    m.extend(Handler)
    m.instance_variable_set(:@app, app)
    m
  end

  def self.handler_from_rack_config_file(path = './config.ru')
    require 'rack'
    require 'rack/builder'
    app = if Rack.release[0] == '2'
      Rack::Builder.load_file(path, {})[0]
    else
      Rack::Builder.load_file(path)
    end
    generate_handler(app)
  end
end
