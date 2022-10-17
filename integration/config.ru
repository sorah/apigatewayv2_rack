require_relative './app'
require 'rack'
require 'logger'

use(Rack::CommonLogger, Logger.new($stdout))
use(Rack::Session::Cookie, key: 'sess', expire_after: 3600, secret: 'insecure-secret')
run App
