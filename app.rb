require 'bundler'
Bundler.require

get '/' do
  erb random_template
end

private

def random_template
  [:nginx, :apache20, :apache22, :rails, :iis7, :h2o].sample
end
