module Dkim
  class Interceptor
    def self.delivering_email(message)
      message['DKIM-Signature'] = SignedMail.new(message.encoded).dkim_header.value
      message
    end
  end
end

