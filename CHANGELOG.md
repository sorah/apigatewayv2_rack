## [Unreleased]

## [0.1.3] - 2023-03-22

- Fixed Errno::EACCES from StringIO when a streaming body (body does not respond to `#each`) is returned
- Raise error when a response body is nil

## [0.1.2] - 2023-03-22

- Fixed Apigatewayv2Rack.handler_from_rack_config_file didn't work well with Rack 3.

## [0.1.1] - 2022-10-17

- `#to_ary` on response body is no longer called to support Rack::CommonLogger and keep compatibility with Rack 2 specification.

## [0.1.0] - 2022-10-17

- Initial release
