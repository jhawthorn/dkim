
module Dkim
  class Interceptor
    def self.delivering_email(message)
      require 'mail/dkim_field'
      require 'mail/register_dkim_field'

      # strip any existing signatures
      if message['DKIM-Signature']
        warn "WARNING: Dkim::Interceptor given a message with an existing signature, which it has replaced."
        warn "If you really want to add a second signature to the message, you should be using the dkim gem directly."
        message['DKIM-Signature'] = nil
      end

      # generate new signature
      dkim_signature = SignedMail.new(message.encoded).dkim_header.value

      # prepend signature to message
      message.header.fields << Mail::Field.new(Mail::DkimField::CAPITALIZED_FIELD, dkim_signature)
      message
    end
  end
end

