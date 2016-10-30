require 'bundler'
Bundler.require

class App < Sinatra::Base

  configure do
    set :sessions, true
    set :inline_templates, true
  end

  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  end

  helpers do
    def redis
      Thread.current[:redis] ||= Redis.new(url: ENV['REDIS_URL'])
    end

    def current_user
      session[:twitter_uid]
    end

    def current_username
      redis.hget('twitter', "#{current_user}:screen_name")
    end

    def require_login(redirect_path = request.path)
      if current_user.nil?
        session[:callback_redirect_path] = redirect_path
        redirect '/auth/twitter'
      end
    end
  end

  get '/auth/:provider/callback' do
    result = request.env['omniauth.auth']
    redis.hset('twitter', "#{result['uid']}:screen_name", result['info']['nickname'])
    session[:twitter_uid] = result['uid']
    redirect session.delete(:callback_redirect_path) || '/'
  end

  get '/' do
    erb random_template
  end

  get '/findmyiphone' do
    @histories = redis.lrange('histories', 0, 19).map{|history| JSON.load(history)}
    erb :findmyiphone
  end

  post '/findmyiphone' do
    if params[:auth] == '1'
      require_login
      requester_info = {
        when: Time.now.iso8601,
        who: "Twitter: <a href=\"https://twitter.com/intent/user?user_id=#{current_user}\">@#{current_username}</a>さん",
      }
      redis.lpush('histories', requester_info.to_json)
      RingMyiPhone.perform_async(ENV['MY_IPHONE_NAME'])
      "多分鳴ったよ"
    else
      redirect '/findmyiphone'
    end
  end

  private

  def random_template
    [:nginx, :apache20, :apache22, :rails, :iis7, :h2o].sample
  end
end
