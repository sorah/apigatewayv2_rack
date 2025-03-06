## [Unreleased]

## [0.2.2] - 2025-03-07

- v0.2.1 accidentially released out of main branch. This release is to fix it.

## [0.2.1] - 2025-03-07

- Address `Rack::VERSION` removal.

## [0.2.0] - 2023-03-24

- `Apigatewayv2Rack.handle_request` now takes a block and pass rack env and `Apigatewayv2Rack::Request` object to allow final modification before passing env to a Rack app.
- `Apigatewayv2Rack.generate_handler` and `handler_from_rack_config_file` propagates given block to `handle_request` for the enhancement above.
- Introduce `Apigatewayv2Rack::Middlewares::CloudfrontXff` and `Apigatewayv2Rack::Middlewares::CloudfrontVerify` as a helper middleware.

## [0.1.3] - 2023-03-22

- Fixed Errno::EACCES from StringIO when a streaming body (body does not respond to `#each`) is returned
- Raise error when a response body is nil

## [0.1.2] - 2023-03-22

- Fixed Apigatewayv2Rack.handler_from_rack_config_file didn't work well with Rack 3.

## [0.1.1] - 2022-10-17

- `#to_ary` on response body is no longer called to support Rack::CommonLogger and keep compatibility with Rack 2 specification.

## [0.1.0] - 2022-10-17

- Initial release
