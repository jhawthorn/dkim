
module Dkim
  class Interceptor
    def self.delivering_email(message)
      require 'mail/dkim_field'

      # strip any existing signatures
      message.header.fields.reject! do |field|
        field.name =~ /^DKIM-Signature$/i
      end

      # generate new signature
      dkim_signature = SignedMail.new(message.encoded).dkim_header.value

      # append signature to message
      message.header.fields << Mail::DkimField.new(dkim_signature)
      message
    end
  end
end

