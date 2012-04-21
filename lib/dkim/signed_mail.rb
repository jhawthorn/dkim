require 'openssl'

require 'dkim/body'
require 'dkim/dkim_header'
require 'dkim/header'
require 'dkim/header_list'
require 'dkim/options'
require 'dkim/canonicalized_headers'

module Dkim
  class SignedMail
    include Options

    # A new instance of SignedMail
    #
    # @param [String,#to_s] message mail message to be signed
    # @param [Hash] options hash of options for signing. Defaults are taken from {Dkim}. See {Options} for details.
    def initialize message, options={}
      message = message.to_s.gsub(/\r?\n/, "\r\n")
      headers, body = message.split(/\r?\n\r?\n/, 2)
      @original_message = message
      @headers = HeaderList.new headers
      @body    = Body.new body

      # default options from Dkim.options
      @options = Dkim.options.merge(options)
    end

    def canonicalized_headers
      CanonicalizedHeaders.new(@headers, signed_headers)
    end

    # @return [Array<String>] lowercased names of headers in the order they are signed
    def signed_headers
      @headers.map(&:relaxed_key).select do |key|
        signable_headers.map(&:downcase).include?(key)
      end
    end

    # @return [String] Signed headers of message in their canonical forms
    def canonical_header
      canonicalized_headers.to_s(header_canonicalization)
    end

    # @return [String] Body of message in its canonical form
    def canonical_body
      @body.to_s(body_canonicalization)
    end

    # @return [DkimHeader] Constructed signature for the mail message
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

    # @return [String] Message combined with calculated dkim header signature
    def to_s
      dkim_header.to_s + "\r\n" + @original_message
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

