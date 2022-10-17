require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    cnt = session[:cnt] || 0
    content_type :html
    "<!DOCTYPE html><html><head><meta charset='utf-8'><title>apigatewayv2_rack test</title><body><p>Hello from Lambda!</p><form method='post'><p><button type='submit'>+</button> #{cnt}</p></form>"
  end

  post '/' do
    session[:cnt] ||= 0
    session[:cnt] += 1
    redirect '/'
  end

  get '/errortown' do
    raise RuntimeError, 'errortown...'
  end
end
