require 'dkim/canonicalizable'

module Dkim
  class Header < Struct.new(:key, :value)
    include Canonicalizable

    def relaxed_key
      key = self.key.dup

      #Convert all header field names (not the header field values) to lowercase.  For example, convert "SUBJect: AbC" to "subject: AbC".
      key.downcase!

      # Delete any WSP characters remaining before the colon separating the header field name from the header field value.
      key.gsub!(/[ \t]*\z/, '')

      key
    end
    def relaxed_value
      value  = self.value.dup

      # Unfold all header field continuation lines as described in [RFC2822]
      value.gsub!(/\r?\n[ \t]+/, ' ')

      # Convert all sequences of one or more WSP characters to a single SP character.
      value.gsub!(/[ \t]+/, ' ')

      # Delete all WSP characters at the end of each unfolded header field value.
      value.gsub!(/[ \t]*\z/, '')
      
      # Delete any WSP characters remaining after the colon separating the header field name from the header field value.
      value.gsub!(/\A[ \t]*/, '')

      value
    end
    def canonical_relaxed
      "#{relaxed_key}:#{relaxed_value}"
    end
    def canonical_simple
      "#{key}:#{value}"
    end

    def self.parse header_string
      header_string.split(/\r?\n(?!([ \t]))/).map do |header|
        key, value = header.split(':', 2)
        new(key, value)
      end
    end
  end
end
