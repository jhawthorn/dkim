
require 'dkim/header'
require 'dkim/header_list'
require 'dkim/body'
require 'dkim/signed_mail'

module Dkim
  DefaultHeaders = %w{
    From Sender Reply-To Subject Date
    Message-ID To Cc MIME-Version
    Content-Type Content-Transfer-Encoding Content-ID Content-Description
    Resent-Date Resent-From Resent-Sender Resent-To Resent-cc
    Resent-Message-ID
    In-Reply-To References
    List-Id List-Help List-Unsubscribe List-Subscribe
    List-Post List-Owner List-Archive}

  class << self
    attr_accessor :signing_algorithm, :signable_headers, :domain, :selector

    attr_reader :private_key
    def private_key= key
      key = OpenSSL::PKey::RSA.new(key) if key.is_a?(String)
      @private_key = key
    end

    def sign message, options={}
      SignedMail.new(message, options).to_s
    end
  end
end

Dkim::signable_headers  = Dkim::DefaultHeaders
Dkim::domain            = nil
Dkim::selector          = nil
Dkim::signing_algorithm = 'rsa-sha256'
Dkim::private_key       = nil

