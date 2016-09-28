require 'bundler'
Bundler.require

get '/' do
  erb random_template
end

private

def random_template
  [:nginx, :apache, :rails].sample
end