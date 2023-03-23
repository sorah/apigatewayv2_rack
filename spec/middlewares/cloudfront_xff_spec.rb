require 'spec_helper'
require 'apigatewayv2_rack/middlewares/cloudfront_xff'

RSpec.describe Apigatewayv2Rack::Middlewares::CloudfrontXff do
  let(:app) { proc { |e|  [200, {env:  e}, []] } }
  let(:viewer_address) { nil }
  let(:env) { {'HTTP_CLOUDFRONT_VIEWER_ADDRESS' => viewer_address, 'REMOTE_ADDR' => '192.0.2.1'}.compact }

  let(:replace_remote_addr_with) { nil }
  subject(:middleware) { described_class.new(app, replace_remote_addr_with: replace_remote_addr_with) }

  subject { middleware.call(env)[1][:env].values_at('HTTP_X_FORWARDED_FOR', 'HTTP_X_FORWARDED_PORT', 'REMOTE_ADDR') }

  context "with no value" do
    let(:viewer_address) { nil }
    it { is_expected.to eq([nil,nil,'192.0.2.1']) }
  end

  context "with valid ipv4 value" do
    let(:viewer_address) { '198.51.100.1:12345' }
    it { is_expected.to eq(['198.51.100.1','12345','192.0.2.1']) }
  end

  context "with valid ipv6 value" do
    let(:viewer_address) { 'fe80::dead:beef:5:8888' }
    it { is_expected.to eq(['fe80::dead:beef:5','8888','192.0.2.1']) }
  end

  context "with replace_remote_addr_with" do
    let(:viewer_address) { '198.51.100.1:12345' }
    let(:replace_remote_addr_with) { '127.0.0.2' }
    it { is_expected.to eq(['198.51.100.1','12345','127.0.0.2']) }
  end
end
