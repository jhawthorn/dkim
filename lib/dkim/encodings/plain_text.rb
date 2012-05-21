module Dkim
  module Encodings
    class PlainText
      def encode v; v; end
      alias_method :decode, :encode
    end
  end
end
