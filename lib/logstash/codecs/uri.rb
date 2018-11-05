# encoding: utf-8
require "logstash/codecs/base"
require "logstash/util/charset"
require "uri"

# This  codec will append a string to the message field
# of an event, either in the decoding or encoding methods
#
# This is only intended to be used as an example.
#
# input {
#   stdin { codec =>  }
# }
#
# or
#
# output {
#   stdout { codec =>  }
# }
#
class LogStash::Codecs::URI < LogStash::Codecs::Base

  # The codec name
  config_name "uri"

  config :charset, :validate => ::Encoding.name_list, :default => "UTF-8"

  def register
    @converter = LogStash::Util::Charset.new(@charset)
    @converter.logger = @logger
  end # def register

  def decode(data)
    data = @converter.convert(data)
    begin
      decoded = URI.decode_www_form(data)
      decoded = decoded.reduce({}) do |memo, item|
        memo.update({item[0] => parse(item[1])}) do |k, oldval, newval|
          [oldval, newval]
        end
      end
      yield LogStash::Event.new(decoded) if block_given?
    rescue URI::Error => e
      @logger.info("message" => "URI parse error: #{e}", "error" => e, "data" => data)
      yield LogStash::Event.new("message" => data, "tags" => ["_uriparsefailure"]) if block_given?
    end
  end # def decode

  # Encode a single event, this returns the raw data to be returned as a String
  def encode_sync(event)
    URI.encode_www_form(event.to_hash)
  end # def encode_sync

  private
  def parse(val)
    if val.is_a?(String)
      if val.match?(/^[0-9.]*$/)
        begin
          if val.include?(".")
            return Float(val)
          else
            return Integer(val)
          end
        rescue ArgumentError, TypeError
          return val
        end
      elsif val.start_with?("{")
        new_val = {}
        v = val.gsub(/{|}/, "")
        v.split(',').each do |vi|
          vi.strip!
          vals = vi.split('=>')
          new_val.update({vals[0].gsub(/"/, "") => vals[1].gsub(/"/, "")})
        end
        return new_val
      end
    end

    return val
  end

end # class LogStash::Codecs::Uri
