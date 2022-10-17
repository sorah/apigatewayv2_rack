$:.unshift(File.join(__dir__, 'lib'))
require 'rack'
require 'rack/builder'
require 'apigatewayv2_rack'


#module Main
#  @app = Rack::Builder.load_file(File.join(__dir__, 'config.ru'), {})[0]
#  def self.handle(event:, context:)
#    puts(JSON.generate(event: event, context: context))
#    retval = Apigatewayv2Rack.handle_request(event: event, context: context, app: @app)
#    puts(JSON.generate(retval))
#    retval
#  end
#end
#def handler(event:, context:)
#  Main.handle(event: event, context: context)
#end

$stdout.sync = true
Main = Apigatewayv2Rack.handler_from_rack_config_file(File.join(__dir__, 'config.ru'))
