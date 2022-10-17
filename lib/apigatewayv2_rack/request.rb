# frozen_string_literal: true
require 'uri'
require 'base64'
require 'rack'
require 'stringio'

require_relative "./error"

module Apigatewayv2Rack
  # Converts API Gateway V2 payload format or ALB event format (ELBv2)
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html
  class Request
    def initialize(event, context, use_x_forwarded_host: false)
      @event = event
      @context = context

      @use_x_forwarded_host = use_x_forwarded_host
    end

    attr_reader :event, :context
    attr_reader :use_x_forwarded_host

    def elb?
      event.dig('requestContext')&.key?('elb')
    end

    def multivalued?
      event.key?('multiValueHeaders')
    end

    def protocol
      event.dig('requestContext', 'http', 'protocol') || 'HTTP/1.1'
    end

    def request_method
      event['httpMethod'] || event.fetch('requestContext').fetch('http').fetch('method')
    end

    def path
      (event['rawPath'] || event['path']) or raise Apigatewayv2Rack::Error.new("neither rawPath and path are defined")
    end

    def query_string
      event['rawQueryString'] || encode_query_string_parameters(event['multiValueQueryStringParameters'] || event['queryStringParameters']) || ''
    end

    private def encode_query_string_parameters(query_string_parameters)
      # alb queryStringParameters does not decode uri escape, but apigatewayv2 does. However apigatewayv2 has rawQueryString so it should have no problem.
      query_string_parameters.flat_map { |k,vs| [*vs].map { |v| "#{k}=#{v}" } }.join('&')
    end

    def body
      @body ||= event['body'] ? (event['isBase64Encoded'] ? Base64.decode64(event['body']) : event['body']) : ''
    end

    def source_ip
      event.dig('requestContext', 'http', 'sourceIp') || '0.0.0.0' # XXX:
    end

    def headers
      # Assume everything is lower-cased
      @headers ||= event['multiValueHeaders']&.transform_values { |v| v.join(',') } || event['headers']
    end

    def headers_as_env
      r = {}
      headers.each do |k,v|
        next if k == 'content-type'
        next if k == 'content-length'
        r["HTTP_#{k.upcase.tr(?-, ?_)}"] = v
      end
      r
    end

    def cookies_as_env
      if event['cookies']
        { 'HTTP_COOKIE' => event['cookies'].join('; ') }
      else
        {}
      end
    end

    def to_h
      {
        'SERVER_PROTOCOL' => protocol,
        'REQUEST_METHOD' => request_method,
        'SCRIPT_NAME' => '',
        'PATH_INFO' => path,
        'QUERY_STRING' => query_string,
        'SERVER_NAME' => headers['host'] || 'unknown',
        'SERVER_PORT' => (use_x_forwarded_host && ['x-forwarded-port']&.to_i&.to_s) || '80',
        'CONTENT_LENGTH' => body.bytesize.to_s,
        'CONTENT_TYPE' => headers['content-type'] || '',
        'REMOTE_ADDR' => source_ip,
        'rack.version' => Rack::VERSION,
        'rack.url_scheme' => (use_x_forwarded_host && headers['x-forwarded-proto']) || 'https',
        'rack.input' => StringIO.new(body),
        'rack.errors' => $stderr,
        'rack.multithread' => false,
        'rack.multiprocess' => false,
        'rack.run_once' => false,
        # compat with serverless-rack gem
        'serverless.event' => event,
        'serverless.context' => context,
        'serverless.authorizer' => nil,
        # itself
        'apigatewayv2.request' => self,
      }
        .merge(headers_as_env)
        .merge(cookies_as_env)
    rescue KeyError => e
      raise Apigatewayv2Rack::Error.new("malformed request: #{e.inspect}")
    end
  end
end
