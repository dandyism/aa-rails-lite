require 'uri'
require_relative '../rails_lite'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = route_params
    @permitted = []

    parse_www_encoded_form(req.query_string) if req.query_string
    parse_www_encoded_form(req.body) if req.body
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted += keys
  end

  def require(key)
    raise AttributeNotFoundError unless @params.has_key?(key)

    @params[key]
  end

  def permitted?(key)
    @permitted.include?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    pairs = URI::decode_www_form(www_encoded_form)
    pairs.map! do |p|
      p[0] = parse_key(p[0])
      [p.first, p.last]
    end

    @params.merge! build_hash(pairs)
  end

  def build_hash(pairs)
    hash = Hash.new

    pairs.each do |pair|
      subhash = hash
      keys = pair.first.is_a?(Array) ? pair.first : [pair.first]
      keys[0...-1].each do |key|
        subhash[key] ||= Hash.new
        subhash = subhash[key]
      end
      subhash[keys.last] = pair.last
    end

    hash
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
