require 'json'
require 'webrick'

class Session

  COOKIE_NAME = "_rails_light_app"

  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie = get_app_cookie(req)
  end

  def [](key)
    cookie[key]
  end

  def []=(key, val)
    cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << new_app_cookie
  end

  private
  attr_accessor :cookie

  def get_app_cookie(req)
    cookie = req.cookies.find { |cookie| cookie.name = COOKIE_NAME }
    cookie.nil? ? {} : JSON::parse(cookie.value)
  end

  def new_app_cookie
    WEBrick::Cookie.new(COOKIE_NAME, self.cookie.to_json)
  end
end
