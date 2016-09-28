require 'bundler'
Bundler.require

get '/' do
  erb :nginx
end
