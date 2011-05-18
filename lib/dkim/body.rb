module Dkim
  class Body < Struct.new(:body)
    def canonical_relaxed
      body = self.body.dup

      # Ignores all whitespace at the end of lines.  Implementations MUST NOT remove the CRLF at the end of the line.
      body.gsub!(/[ \t]+(?=\r\n|\z)/, '')

      # Reduces all sequences of WSP within a line to a single SP character.
      body.gsub!(/[ \t]+/, ' ')

      # Ignores all empty lines at the end of the message body.
      body.gsub!(/(\r?\n)*\z/, '')
      body += "\r\n"
    end
    def canonical_simple
      body = self.body.dup

      # Ignores all empty lines at the end of the message body.
      body.gsub!(/(\r?\n)*\z/, '')
      body += "\r\n"
    end
    def to_s form='simple'
      case form
      when 'simple'
        canonical_simple
      when 'relaxed'
        canonical_relaxed
      else
        raise "Unknown canonicalization: #{form}"
      end
    end
  end
end
