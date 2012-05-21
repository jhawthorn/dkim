module Dkim
  module Encodings
    class Base64
      def decode data
        data.gsub(/\s/, '').unpack('m0')[0]
      end
      def encode data
        [data].pack('m0').gsub("\n", '')
      end
    end
  end
end
