require 'uri'
require 'byebug'

module Phase7
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = route_params
      @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
      @params.merge!(parse_www_encoded_form(req.body)) if req.body
    end

    def [](key)
      key = key.to_s
      @params[key]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      x = URI::decode_www_form(www_encoded_form)
      result = {}
      x.each do |arr|
        parsed_keys = parse_key(arr.first)
        value = arr.last
        location_in_result = result
        parsed_keys.each_with_index do |parsed_key, i|
          if location_in_result.keys.include?(parsed_key)
            location_in_result = location_in_result[parsed_key]
          else
            location_in_result[parsed_key] = (i == parsed_keys.length - 1 ? value : {} )
            location_in_result = location_in_result[parsed_key]
          end
        end
      end

      result
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end