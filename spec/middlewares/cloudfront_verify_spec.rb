require 'spec_helper'
require 'apigatewayv2_rack/middlewares/cloudfront_verify'

RSpec.describe Apigatewayv2Rack::Middlewares::CloudfrontVerify do
  let(:app) { double('app should not be called') }
  let(:env) { {'HTTP_X_ORIGIN_VERIFY' => verifier}.compact }

  subject(:middleware) { described_class.new(app, 'verifier') }

  subject { middleware.call(env)[0] }

  context "with no value" do
    let(:verifier) { nil }
    it { is_expected.to eq(401) }
  end

  context "with invalid value" do
    let(:verifier) { 'x' }
    it { is_expected.to eq(401) }
  end

  context "with expected value" do
    let(:verifier) { 'verifier' }
    let(:app) { proc {  [200, {}, []] } }
    it { is_expected.to eq(200) }
  end
end
