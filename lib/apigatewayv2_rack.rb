# frozen_string_literal: true

require_relative "apigatewayv2_rack/version"
require_relative "apigatewayv2_rack/error"
require_relative "apigatewayv2_rack/request"
#require_relative "apigatewayv2_rack/response"

module Apigatewayv2Rack
  # Takes Rack +app+, Lambda +event+ and +context+ of API Gateway V2 event and
  # returns a HTTP response from +app+ as API Gateway V2 Lambda event format.
  def self.handle_request(app:, event:, context:, request_options: {})
    req = Request.new(event, context, **request_options)
    status, headers, body = app.call(req.to_h)
    Response.new(status: status, headers: headers, body: body).as_json
  end
end
