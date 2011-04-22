module Dkim
  class Header < Struct.new(:key, :value)
    def to_canonical
      key    = self.key.dup
      value  = self.value.dup

      #Convert all header field names (not the header field values) to lowercase.  For example, convert "SUBJect: AbC" to "subject: AbC".
      key.downcase!

      # Unfold all header field continuation lines as described in [RFC2822]
      value.gsub!(/\r?\n[ \t]+/, ' ')

      # Convert all sequences of one or more WSP characters to a single SP character.
      value.gsub!(/[ \t]+/, ' ')

      # Delete all WSP characters at the end of each unfolded header field value.
      value.gsub!(/[ \t]*\z/, '')
      
      # Delete any WSP characters remaining before and after the colon separating the header field name from the header field value.
      value.gsub!(/\A[ \t]*/, '')
      key.gsub!(/[ \t]*\z/, '')

      "#{key}:#{value}"
    end
    def to_s
      "#{key}:#{value}"
    end
  end
end
