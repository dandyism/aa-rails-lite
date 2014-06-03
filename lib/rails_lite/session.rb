require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    self.cookie = get_app_cookie(req)
  end

  def [](key)
    self.cookie[key]
  end

  def []=(key, val)
    self.cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
  end

  private
  attr_accessor :cookie

  def get_app_cookie(req)
    cookie = req.cookies.select { |cookie| cookie.name = "_rails_light_app"}
    cookie.nil? ? {} : JSON::parse(cookie.value)
  end
end
