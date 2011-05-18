module Dkim
  module Canonicalizable
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
