# frozen_string_literal: true
require 'uri'
require 'base64'
require 'rack'
require 'forwardable'
require 'stringio'

require_relative "./error"

module Apigatewayv2Rack
  # Convert rack response to API Gateway V2 event response or ALB lambda target response (ELBv2)
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html
  class Response
    def initialize(status:, headers:, body:, elb: false, multivalued: false)
      @status = status
      @headers = headers
      @body = body

      @elb = elb
      @multivalued = multivalued
    end

    attr_reader :status, :headers, :body

    def elb?
      @elb
    end

    def multivalued?
      @multivalued
    end

    private def consume_body
      case
      when body.nil?
        raise TypeError, "Rack app returned nil body"
      # FIXME: Rack::CommonLogger uses Rack::BodyProxy, which performs logging when body is closed, is not compatible with #to_ary on Rack 3 specification
      # when body.respond_to?(:to_ary)
      #   body.to_ary.join
      when body.respond_to?(:each)
        buf = String.new
        body.each { |chunk| buf << chunk.b }
        body.close if body.respond_to?(:close)
        buf
      else
        stream = StringIO.new(String.new, 'w')
        body.call(stream)
        stream.string
      end
    end

    private def header_value(v_or_vs)
      if v_or_vs.kind_of?(Array)
        v_or_vs
      else
        v_or_vs.split(?\n)
      end
    end

    def headers_as_response
      case
      when elb? && multivalued?
        {multiValueHeaders: headers.map { |k,v| [k.downcase, header_value(v)] }.to_h}
      when elb?
        {headers: headers.map { |k,v| [k.downcase, header_value(v).join(?,)] }.to_h}
      else
        {headers: headers.map { |k,v|  [k.downcase, header_value(v).join(?,)] }.reject { |k,v| k == 'set-cookie' }.to_h}
      end
    end

    def cookies_as_response
      if elb?
        {}
      else
        hdr = headers.find { |k,_v|  k.downcase == 'set-cookie' }
        return {} unless hdr
        { cookies: header_value(hdr[1]) }
      end
    end

    def as_json
      {
        statusCode: status,
        isBase64Encoded: true,
        body: Base64.strict_encode64(consume_body),
      }
        .merge(headers_as_response)
        .merge(cookies_as_response)
    end
  end
end

