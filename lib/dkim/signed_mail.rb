require 'openssl'
require 'base64'

module Dkim
  class SignedMail
    attr_accessor :private_key

    DefaultHeaders = %w{
      From Sender Reply-To Subject Date
      Message-ID To Cc MIME-Version
      Content-Type Content-Transfer-Encoding Content-ID Content-Description
      Resent-Date Resent-From Resent-Sender Resent-To Resent-cc
      Resent-Message-ID
      In-Reply-To References
      List-Id List-Help List-Unsubscribe List-Subscribe
      List-Post List-Owner List-Archive}

    def initialize message
      headers, body = message.split(/\r?\n\r?\n/, 2)
      @headers = HeaderList.new headers
      @body = Body.new body

      @alg = "rsa-sha256"
      @signable_headers = DefaultHeaders.dup
    end
    def signed_headers
      (@headers.map(&:key) & @signable_headers).sort
    end
    def domain
      @headers['From'].value.split('@').last
    end
    def time
      @time ||= Time.now
    end
    def dkim_header_values(b)
      [
        'v',  1,
        'a',  @alg,
        'c',  'relaxed/relaxed',
        'd',  domain,
        'q',  'dns/txt',
        's',  'mail',
        't',  time.to_i,
        'bh', body_hash,
        'h',  signed_headers.join(':'),
        'b',  b
      ]
    end
    def dkim_header(b=nil)
      b ||= header_signature
      value = dkim_header_values(b).each_slice(2).map do |(key, value)|
        "#{key}=#{value}"
      end.join('; ')
      Header.new('DKIM-Signature', value)
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
      case @alg
      when 'rsa-sha1'
        OpenSSL::Digest::SHA1.new
      when 'rsa-sha256' 
        OpenSSL::Digest::SHA256.new
      else
        raise "Unknown digest algorithm: '#{@alg}'"
      end
    end
  end
end
