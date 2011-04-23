require 'openssl'
require 'base64'

module Dkim
  class SignedMail
    EMAIL_REGEX = /[A-Z0-9._%+-]+@([A-Z0-9.-]+\.[A-Z]{2,6})/i

    def initialize message
      headers, body = message.split(/\r?\n\r?\n/, 2)
      @headers = HeaderList.new headers
      @body    = Body.new body

      @signable_headers  = nil
      @domain            = nil
      @selector          = nil
      @time              = nil
      @signing_algorithm = nil
      @private_key       = nil
    end

    # options for signatures
    attr_writer :signing_algorithm, :signable_headers, :domain, :selector, :time

    def private_key= key
      key = OpenSSL::PKey::RSA.new(key) if key.is_a?(String)
      @private_key = key
    end
    def private_key
      @private_key || Dkim::private_key
    end
    def signing_algorithm
      @signing_algorithm || Dkim::signing_algorithm
    end
    def signable_headers
      @signable_headers || Dkim::signable_headers
    end
    def domain
      @domain || Dkim::domain || (@headers['From'].value =~ EMAIL_REGEX && $1)
    end
    def selector
      @selector || Dkim::selector
    end
    def time
      @time ||= Time.now
    end

    def signed_headers
      (@headers.map(&:key) & signable_headers).sort
    end
    def dkim_header_values(b)
      [
        'v',  1,
        'a',  signing_algorithm,
        'c',  'relaxed/relaxed',
        'd',  domain,
        'q',  'dns/txt',
        's',  selector,
        't',  time.to_i,
        'bh', body_hash,
        'h',  signed_headers.join(':'),
        'b',  b
      ]
    end
    def dkim_header(b=nil)
      b ||= header_signature
      v = dkim_header_values(b).each_slice(2).map do |(key, value)|
        "#{key}=#{value}"
      end.join('; ')
      Header.new('DKIM-Signature', v)
    end
    def canonical_header
      headers = signed_headers.map do |key|
        @headers[key]
      end
      headers << dkim_header('')
      headers.map(&:to_canonical).join("\r\n")
    end
    def canonical_body
      @body.to_canonical
    end

    def header_signature
      base64_encode private_key.sign(digest_alg, canonical_header)
    end
    def body_hash
      base64_encode digest_alg.digest(canonical_body)
    end
    def to_s
      headers = @headers.to_a + [dkim_header]
      headers.map(&:to_s).join("\r\n") +
        "\r\n\r\n" +
        @body.to_s
    end

    private
    def base64_encode data
      Base64.encode64(data).gsub("\n",'')
    end
    def digest_alg
      case signing_algorithm
      when 'rsa-sha1'
        OpenSSL::Digest::SHA1.new
      when 'rsa-sha256' 
        OpenSSL::Digest::SHA256.new
      else
        raise "Unknown digest algorithm: '#{signing_algorithm}'"
      end
    end
  end
end

