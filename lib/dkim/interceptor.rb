
module Dkim
  class Interceptor
    def self.delivering_email(message)
      require 'mail/dkim_field'
      message.header.fields << Mail::DkimField.new(SignedMail.new(message.encoded).dkim_header.value)
      message
    end
  end
end

