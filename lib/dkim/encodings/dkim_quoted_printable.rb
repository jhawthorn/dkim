
module Dkim
  module Encodings
    # Implements DKIM-Quoted-Printable as described in rfc6376 section 2.11
    class DkimQuotedPrintable
      DkimUnafeChar = /[^\x21-\x3A\x3C\x3E-\x7E]/
      def encode string
        string.gsub(DkimUnafeChar) do |char|
          "=%.2x" % char.ord
        end
      end
      def decode string
        string.gsub(/=([0-9A-F]{2})/) do
          $1.hex.chr
        end
      end
    end
  end
end
