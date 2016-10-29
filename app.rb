require 'bundler'
Bundler.require

class App < Sinatra::Base
  get '/' do
    erb random_template
  end

  get '/findmyiphone' do
    @last_ip = redis.get('last_ip')
    erb :findmyiphone
  end

  post '/findmyiphone' do
    if params[:auth] == '1'
      redis.set('last_ip', request.ip)
      RingMyiPhone.perform_async(ENV['MY_IPHONE_NAME'])
      "多分鳴ったよ"
    else
      redirect '/findmyiphone'
    end
  end

  private

  def redis
    Thread.current[:redis] ||= Redis.new(url: ENV['REDIS_URL'])
  end

  def random_template
    [:nginx, :apache20, :apache22, :rails, :iis7, :h2o].sample
  end
end
