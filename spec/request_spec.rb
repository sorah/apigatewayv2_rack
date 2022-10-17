require 'spec_helper'
require 'apigatewayv2_rack/request'

RSpec.describe Apigatewayv2Rack::Request do
  let(:input_context) { double('lambda context') }
  let(:event) { raise 'undefined' }
  let(:request) { Apigatewayv2Rack::Request.new(event, input_context) }
  subject { request.to_h }

  describe "parsing normal apigatewayv2 request" do
    subject { request.to_h.tap { |_| _.delete('rack.input') } }

    let(:event) do
      {
        "version" => "2.0",
        "routeKey" => "$default",
        "rawPath" => "/apiv2-1",
        "rawQueryString" => "%E3%81%82=%E3%81%82",
        "cookies" => ["%E3%81%82=%E3%81%82", "a=b"],
        "headers" => {
          "x-amzn-tls-cipher-suite" => "ECDHE-RSA-AES128-GCM-SHA256",
          "x-amzn-tls-version" => "TLSv1.2",
          "x-amzn-trace-id" => "Root=1-634c7c63-28e1f41105a460b7516bd589",
          "cookie" => "a=b",
          "x-forwarded-proto" => "https",
          "host" => "dummy.lambda-url.ap-northeast-1.on.aws.invalid",
          "x-forwarded-port" => "443",
          "x-forwarded-for" => "2002:db8:dead:beef:210:5daa:feee:505",
          "accept" => "*/*",
          "user-agent" => "curl/7.85.0"
        },
        "queryStringParameters" => {"あ" => "あ"},
        "requestContext" => {
          "accountId" => "anonymous",
          "apiId" => "dummy",
          "domainName" => "dummy.lambda-url.ap-northeast-1.on.aws.invalid",
          "domainPrefix" => "dummy",
          "http" => {
            "method" => "GET",
            "path" => "/",
            "protocol" => "HTTP/1.1",
            "sourceIp" => "2002:db8:dead:beef:210:5daa:feee:505",
            "userAgent" => "curl/7.85.0"
          },
          "requestId" => "c3d6a63f-b04f-4ea2-8930-ec92dccf9c5e",
          "routeKey" => "$default",
          "stage" => "$default",
          "time" => "16/Oct/2022:21:49:23 +0000",
          "timeEpoch" => 1665956963597
        },
        "isBase64Encoded" => false,
      }
    end

    it "marks request as non-elb" do
      expect(request.elb?).to eq(false)
    end

    it { is_expected.to eq(
      'SERVER_PROTOCOL' => 'HTTP/1.1',
      'REQUEST_METHOD' => 'GET',
      'SCRIPT_NAME' => '',
      'PATH_INFO' => '/apiv2-1',
      'QUERY_STRING' => "%E3%81%82=%E3%81%82",
      'SERVER_NAME' => 'dummy.lambda-url.ap-northeast-1.on.aws.invalid',
      'SERVER_PORT' => '80',
      'CONTENT_LENGTH' => '0',
      'CONTENT_TYPE' => '',
      'REMOTE_ADDR' => '2002:db8:dead:beef:210:5daa:feee:505',
      'rack.version' => Rack::VERSION,
      'rack.url_scheme' => 'https',
      'rack.errors' => $stderr,
      'rack.multithread' => false,
      'rack.multiprocess' => false,
      'rack.run_once' => false,
      'serverless.event' => event,
      'serverless.context' => input_context,
      'serverless.authorizer' => nil,
      'apigatewayv2.request' => request,
      'HTTP_X_AMZN_TLS_CIPHER_SUITE' => 'ECDHE-RSA-AES128-GCM-SHA256',
      'HTTP_X_AMZN_TLS_VERSION' => 'TLSv1.2',
      'HTTP_X_AMZN_TRACE_ID' => 'Root=1-634c7c63-28e1f41105a460b7516bd589',
      'HTTP_X_FORWARDED_PROTO' => 'https',
      'HTTP_HOST' => 'dummy.lambda-url.ap-northeast-1.on.aws.invalid',
      'HTTP_X_FORWARDED_PORT' => '443',
      'HTTP_X_FORWARDED_FOR' => '2002:db8:dead:beef:210:5daa:feee:505',
      'HTTP_ACCEPT' => '*/*',
      'HTTP_USER_AGENT' => 'curl/7.85.0',
      'HTTP_COOKIE' => '%E3%81%82=%E3%81%82; a=b',
    ) }
  end

  describe "parsing normal apigatewayv2 request with body" do
    let(:event) do
      {
        "version" => "2.0",
        "routeKey" => "$default",
        "rawPath" => "/apiv2-2",
        "rawQueryString" => "",
        "headers" => {
          "host" => "dummy.lambda-url.ap-northeast-1.on.aws.invalid",
          "content-type" => "text/plain",
          "content-length" => "3",
          "user-agent" => "curl/7.85.0",
        },
        "requestContext" => {
          "http" => {
            "method" => "POST",
            "path" => "/",
            "protocol" => "HTTP/1.1",
            "sourceIp" => "2002:db8::1",
            "userAgent" => "curl/7.85.0"
          },
          "requestId" => "c3d6a63f-b04f-4ea2-8930-ec92dccf9c5e",
          "routeKey" => "$default",
          "stage" => "$default",
          "time" => "16/Oct/2022:21:49:23 +0000",
          "timeEpoch" => 1665956963597
        },
        "body" => "foo",
        "isBase64Encoded" => false,
      }
    end

    it "returns rack.input" do
      expect(subject.fetch('CONTENT_TYPE')).to eq('text/plain')
      expect(subject.fetch('CONTENT_LENGTH')).to eq('3')
      expect(subject.fetch('rack.input').read).to eq('foo')
    end
  end

  describe "parsing normal apigatewayv2 request with b64body" do
    let(:event) do
      {
        "version" => "2.0",
        "routeKey" => "$default",
        "rawPath" => "/apiv2-3",
        "rawQueryString" => "",
        "headers" => {
          "host" => "dummy.lambda-url.ap-northeast-1.on.aws.invalid",
          "content-type" => "text/plain",
          "content-length" => "3",
          "user-agent" => "curl/7.85.0",
        },
        "requestContext" => {
          "http" => {
            "method" => "POST",
            "path" => "/",
            "protocol" => "HTTP/1.1",
            "sourceIp" => "2002:db8::1",
            "userAgent" => "curl/7.85.0"
          },
          "requestId" => "c3d6a63f-b04f-4ea2-8930-ec92dccf9c5e",
          "routeKey" => "$default",
          "stage" => "$default",
          "time" => "16/Oct/2022:21:49:23 +0000",
          "timeEpoch" => 1665956963597
        },
        "body" => Base64.encode64("foo"),
        "isBase64Encoded" => true,
      }
    end

    it "returns rack.input" do
      expect(subject.fetch('CONTENT_TYPE')).to eq('text/plain')
      expect(subject.fetch('CONTENT_LENGTH')).to eq('3')
      expect(subject.fetch('rack.input').read).to eq('foo')
    end
  end

  describe "parsing alb request" do
    subject { request.to_h.tap { |_| _.delete('rack.input') } }

    let(:event) do
      {
        "requestContext" => {
          "elb"  =>  {"targetGroupArn"  =>  "arn:aws:elasticloadbalancing:ap-northeast-1:000000000000:targetgroup/sorahtmp/ffffffffffffffff"},
        },
        "httpMethod" => "GET",
        "path" => "/alb-1",
        "queryStringParameters" => {"%E3%81%82" => "%E3%81%82"},
        "headers" => {
          "accept" => "*/*",
          "cookie" => "%E3%81%82=%E3%81%82; a=b",
          "host" => "sorahtmp-0000000000.ap-northeast-1.elb.amazonaws.com",
          "user-agent" => "curl/7.85.0",
          "x-amzn-trace-id" => "Root=1-634c81e9-5b69b2d541b202de26524afc",
          "x-forwarded-for" => "192.0.2.1",
          "x-forwarded-port" => "80",
          "x-forwarded-proto" => "http",
        },
        "body" => "",
        "isBase64Encoded" => false,
      }
    end

    it "marks request as elb" do
      expect(request.elb?).to eq(true)
    end

    it "marks request as non-multivalued" do
      expect(request.multivalued?).to eq(false)
    end

    it { is_expected.to eq(
      'SERVER_PROTOCOL' => 'HTTP/1.1',
      'REQUEST_METHOD' => 'GET',
      'SCRIPT_NAME' => '',
      'PATH_INFO' => '/alb-1',
      'QUERY_STRING' => "%E3%81%82=%E3%81%82",
      'SERVER_NAME' => 'sorahtmp-0000000000.ap-northeast-1.elb.amazonaws.com',
      'SERVER_PORT' => '80',
      'CONTENT_LENGTH' => '0',
      'CONTENT_TYPE' => '',
      'REMOTE_ADDR' => '0.0.0.0',
      'rack.version' => Rack::VERSION,
      'rack.url_scheme' => 'https',
      'rack.errors' => $stderr,
      'rack.multithread' => false,
      'rack.multiprocess' => false,
      'rack.run_once' => false,
      'serverless.event' => event,
      'serverless.context' => input_context,
      'serverless.authorizer' => nil,
      'apigatewayv2.request' => request,
      'HTTP_ACCEPT' => '*/*',
      'HTTP_COOKIE' => '%E3%81%82=%E3%81%82; a=b',
      'HTTP_HOST' => 'sorahtmp-0000000000.ap-northeast-1.elb.amazonaws.com',
      'HTTP_USER_AGENT' => 'curl/7.85.0',
      'HTTP_X_AMZN_TRACE_ID' => 'Root=1-634c81e9-5b69b2d541b202de26524afc',
      'HTTP_X_FORWARDED_FOR' => '192.0.2.1',
      'HTTP_X_FORWARDED_PORT' => '80',
      'HTTP_X_FORWARDED_PROTO' => 'http',
    ) }
  end

  describe "parsing alb request with b64body" do
    let(:event) do
      {
        "requestContext" => {
          "elb"  =>  {"targetGroupArn"  =>  "arn:aws:elasticloadbalancing:ap-northeast-1:000000000000:targetgroup/sorahtmp/ffffffffffffffff"},
        },
        "httpMethod" => "POST",
        "path" => "/alb-2",
        "queryStringParameters" => {},
        "headers" => {
          "accept" => "*/*",
          "content-length" => "3",
          "content-type" => "text/plain",
          "host" => "sorahtmp-0000000000.ap-northeast-1.elb.amazonaws.com",
          "user-agent" => "curl/7.85.0",
          "x-amzn-trace-id" => "Root=1-634c81ff-0d2c0a083143a2df1a01f98f",
          "x-forwarded-for" => "192.0.2.1",
          "x-forwarded-port" => "80",
          "x-forwarded-proto" => "http",
        },
        "body" => Base64.encode64("foo"),
        "isBase64Encoded" => true,
      }
    end

    it "returns rack.input" do
      expect(subject.fetch('CONTENT_TYPE')).to eq('text/plain')
      expect(subject.fetch('CONTENT_LENGTH')).to eq('3')
      expect(subject.fetch('rack.input').read).to eq('foo')
    end
  end
end
