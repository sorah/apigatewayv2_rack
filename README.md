# apigatewayv2_rack: serve Rack app from AWS Lambda function via API Gateway V2 (HTTP API) or ALB (ELB v2) lambda target

Apigatewayv2Rack provides a method to convert a AWS Lambda invocation event from API Gateway V2 (HTTP API) or ALB lambda target (ELBv2) to a Rack request environment and a method to convert a Rack response tuple to a corresponding Lambda response object.

This gem also provides support for Lambda function URL as it uses the same schema with API Gateway V2.

## Supported deployment and limitation

- Supports Rack 2 and Rack 3 specification
- The following AWS Lambda invocation event schemas:
  - [Amazon API Gateway HTTP API payload version 2.0](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html)
  - [ALB lambda function target](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html)
- Multiple field lines are not supported on API Gateway schema except `set-cookie` header due to API Gateway's limitation
- `lambda.multi_value_headers.enabled` is recommended to be set for usage with ALB. <sup>[[doc](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html#enable-multi-value-headers)]</sup>

## Usage

### Quick usage

```ruby
# Gemfile
gem 'apigatewayv2_rack'
```

```ruby
# main.rb
require 'apigatewayv2_rack'
Main = Apigatewayv2Rack.handler_from_rack_config_file(File.join(__dir__, 'config.ru'))
```

And set lambda function handler to `main.Main.handle` then voila!

### Non-quick usage

```ruby
req = Apigatewayv2Rack::Request.new(event: event, context: context)
status, headers, body = rack_app.call(req.to_h)
resp = Apigatewayv2Rack::Response.new(status: status, headers: headers, body: body, elb: req.elb?, multivalued: req.multivalued?)
p resp.as_json
```

### Full example

See [./Dockerfile.integration](./Dockerfile.integration) and [./integration](./integration).

### Middlewares

This gem includes several utility middlewares:

- [CloudfrontVerify](./lib/apigatewayv2_rack/middlewares/cloudfront_verify.rb): Verify `x-origin-verify` value to protect unwanted direct access.
- [CloudfrontXff](./lib/apigatewayv2_rack/middlewares/cloudfront_xff.rb): Respect `cloudfront-viewer-address` as `x-forwarded-for` value.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/apigatewayv2_rack.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
