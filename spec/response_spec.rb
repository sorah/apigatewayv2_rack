require 'spec_helper'
require 'apigatewayv2_rack/response'

RSpec.describe Apigatewayv2Rack::Response do
  let(:status) { 418 }
  let(:headers) { {"content-type" => "text/plain", 'cache-control' => ['public']} }
  let(:body) { ["I'm a", " teapot"] }
  let(:is_elb) { false }
  let(:is_multivalued) { false }

  let(:response) { described_class.new(status: status, headers: headers, body: body, elb: is_elb, multivalued: is_multivalued) }
  subject { response.as_json }

  describe "encoding simple response" do
    it { is_expected.to eq(
      statusCode: 418,
      headers: {'content-type' => 'text/plain', 'cache-control' => 'public'},
      body: Base64.encode64("I'm a teapot"),
      isBase64Encoded: true
    ) }
  end

  describe "encoding response with stringio" do
    let(:body) { StringIO.new("I'm a teapot\n...") }

    it { is_expected.to eq(
      statusCode: 418,
      headers: {'content-type' => 'text/plain', 'cache-control' => 'public'},
      body: Base64.encode64("I'm a teapot\n..."),
      isBase64Encoded: true
    ) }
  end

  describe "encoding response with cookies in array" do
    let(:status) { 200 }
    let(:headers) { {"content-type" => "text/plain", 'set-cookie' => ['akiyama=mizuki; Max-Age=10', 'shinonome=ena; Max-Age=10']} }
    let(:body) { [] }

    context "for apigatewayv2" do
      it { is_expected.to eq(
        statusCode: 200,
        headers: {'content-type' => 'text/plain'},
        cookies: ['akiyama=mizuki; Max-Age=10', 'shinonome=ena; Max-Age=10'],
        body: Base64.encode64(""),
        isBase64Encoded: true
      ) }
    end

    context "for multivalued elb" do
      let(:is_elb) { true }
      let(:is_multivalued) { true }
      it { is_expected.to eq(
        statusCode: 200,
        multiValueHeaders: {"content-type" => ["text/plain"], 'set-cookie' => ['akiyama=mizuki; Max-Age=10', 'shinonome=ena; Max-Age=10']},
        body: Base64.encode64(""),
        isBase64Encoded: true
      ) }
    end
  end
  describe "encoding response with cookies in string" do
    let(:status) { 200 }
    let(:headers) { {"content-type" => "text/plain", 'set-cookie' => ['akiyama=mizuki; Max-Age=10', 'shinonome=ena; Max-Age=10'].join(?\n)} }
    let(:body) { [] }

    context "for apigatewayv2" do
      it { is_expected.to eq(
        statusCode: 200,
        headers: {'content-type' => 'text/plain'},
        cookies: ['akiyama=mizuki; Max-Age=10', 'shinonome=ena; Max-Age=10'],
        body: Base64.encode64(""),
        isBase64Encoded: true
      ) }
    end

    context "for multivalued elb" do
      let(:is_elb) { true }
      let(:is_multivalued) { true }
      it { is_expected.to eq(
        statusCode: 200,
        multiValueHeaders: {"content-type" => ["text/plain"], 'set-cookie' => ['akiyama=mizuki; Max-Age=10', 'shinonome=ena; Max-Age=10']},
        body: Base64.encode64(""),
        isBase64Encoded: true
      ) }
    end
  end
end

