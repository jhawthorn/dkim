require 'openssl'

require 'dkim/body'
require 'dkim/dkim_header'
require 'dkim/header'
require 'dkim/header_list'
require 'dkim/options'

module Dkim
  class SignedMail
    include Options

    def initialize message, options={}
      message = message.to_s.gsub(/\r?\n/, "\r\n")
      headers, body = message.split(/\r?\n\r?\n/, 2)
      @headers = HeaderList.new headers
      @body    = Body.new body

      # default options from Dkim.options
      @options = Dkim.options.merge(options)
    end

    def signed_headers
      (@headers.map(&:relaxed_key) & signable_headers.map(&:downcase)).sort
    end
    def canonical_header
      headers = signed_headers.map do |key|
        @headers[key].to_s(header_canonicalization) + "\r\n"
      end.join
    end
    def canonical_body
      @body.to_s(body_canonicalization)
    end

    def dkim_header
      dkim_header = DkimHeader.new

      raise "A private key is required" unless private_key
      raise "A domain is required"      unless domain
      raise "A selector is required"    unless selector

      # Add basic DKIM info
      dkim_header['v'] = '1'
      dkim_header['a'] = signing_algorithm
      dkim_header['c'] = "#{header_canonicalization}/#{body_canonicalization}"
      dkim_header['d'] = domain
      dkim_header['q'] = 'dns/txt'
      dkim_header['s'] = selector
      dkim_header['t'] = (time || Time.now).to_i

      # Add body hash and blank signature
      dkim_header['bh']= base64_encode digest_alg.digest(canonical_body)
      dkim_header['h'] = signed_headers.join(':')
      dkim_header['b'] = ''

      # Calculate signature based on intermediate signature header
      headers = canonical_header
      headers << dkim_header.to_s(header_canonicalization)
      signature = base64_encode private_key.sign(digest_alg, headers)
      dkim_header['b'] = signature

      dkim_header
    end

    def to_s
      # Return the original message with the calculated header
      headers = @headers.to_a + [dkim_header]
      headers.map(&:to_s).join("\r\n") +
        "\r\n\r\n" +
        @body.to_s
    end

    private
    def base64_encode data
      [data].pack('m0').gsub("\n",'')
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

