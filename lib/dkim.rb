
require 'dkim/signed_mail'
require 'dkim/options'
require 'dkim/interceptor'

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
    include Dkim::Options

    def sign message, options={}
      SignedMail.new(message, options).to_s
    end
  end
end

Dkim::signable_headers        = Dkim::DefaultHeaders.dup
Dkim::domain                  = nil
Dkim::identity                = nil
Dkim::selector                = nil
Dkim::signing_algorithm       = 'rsa-sha256'
Dkim::private_key             = nil
Dkim::header_canonicalization = 'relaxed'
Dkim::body_canonicalization   = 'relaxed'

