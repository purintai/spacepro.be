require 'bundler'
Bundler.require

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
    res = icloud_request :post, "fmipservice/client/web/initClient"
    devices =  Hash[res['content'].collect{ |device| [device['name'], device] }]
    device = devices['Wi-Fi死んだ時に挙げる札']
    icloud_request :post, "fmipservice/client/web/playSound", body: {device: device['id'], subject: 'alert'}.to_json
    "鳴らしたよ battery=#{device['batteryLevel']}"
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

def icloud_request(method, url, **args)
  unless @cookies
    @cookies = HTTParty::CookieHash.new

    res = HTTParty.post "https://setup.icloud.com/setup/ws/1/login",
      headers: {
        "Origin" => "https://www.icloud.com"
      },
      body: {
        apple_id: ENV['ICLOUD_EMAIL'],
        password: ENV['ICLOUD_PASSWORD'],
      }.to_json

    @url = JSON.parse(res.body)["webservices"]["findme"]["url"]

    @cookies.add_cookies(res.headers["Set-Cookie"])
  end

  args[:headers] = {
    "Origin" => "https://www.icloud.com",
    "Cookie" => @cookies.to_cookie_string
  }
  HTTParty.public_send method, "#{@url}/#{url}", **args
end