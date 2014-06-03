require 'json'
require 'webrick'

class Session

  COOKIE_NAME = "_rails_lite_app"

  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @cookie = get_app_cookie(req)
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << new_app_cookie
  end

  private

  def get_app_cookie(req)
    new_cookie = req.cookies.find { |c| c.to_s.match(/#{COOKIE_NAME}/) }
    cookie_hash = new_cookie.nil? ? '{}' : new_cookie.value
    cookie_hash == "null" ? {} : JSON::parse(cookie_hash)
  end

  def new_app_cookie
    WEBrick::Cookie.new(COOKIE_NAME, @cookie.to_json)
  end
end
