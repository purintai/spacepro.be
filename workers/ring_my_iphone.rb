class RingMyiPhone
  include SuckerPunch::Job

  def perform(device_name)
    res = icloud_request :post, "fmipservice/client/web/initClient"
    devices =  Hash[res['content'].collect{ |device| [device['name'], device] }]
    device = devices[device_name]
    icloud_request :post, "fmipservice/client/web/playSound", body: {device: device['id'], subject: 'alert'}.to_json
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
end