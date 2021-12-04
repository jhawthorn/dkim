module Dkim
  module Options
    private
    def self.define_option_method attribute_name
      define_method(attribute_name){options[attribute_name]}
      define_method("#{attribute_name}="){|value| options[attribute_name] = value}
    end
    public

    # @attribute [rw]
    # Hash of all options
    # @return [Hash]
    def options
      @options ||= {}
    end
    attr_writer :options

    # @attribute [rw]
    # This corresponds to the t= tag in the dkim header.
    # The default (nil) is to use the current time at signing.
    # @return [Time,#to_i] A Time object or seconds since the epoch
    define_option_method :time

    # @attribute [rw]
    # Signature expiration.
    # This corresponds to the x= tag in the dkim header.
    # @return [Time,#to_i] A Time object or seconds since the epoch
    define_option_method :expire

    # @attribute [rw]
    # The signing algorithm for dkim. Valid values are 'rsa-sha1' and 'rsa-sha256' (default).
    # This corresponds to the a= tag in the dkim header.
    # @return [String] signing algorithm
    define_option_method :signing_algorithm

    # @attribute [rw]
    # Configures which headers should be signed.
    # Defaults to {Dkim::DefaultHeaders Dkim::DefaultHeaders}
    # @return [Array<String>] signable headers
    define_option_method :signable_headers

    # @attribute [rw]
    # The domain used for signing.
    # This corresponds to the d= tag in the dkim header.
    # @return [String] domain
    define_option_method :domain

    # @attribute [rw]
    # The identity used for signing.
    # This corresponds to the i= tag in the dkim header.
    # @return [String] identity
    define_option_method :identity

    # @attribute [rw]
    # Selector used for signing.
    # This corresponds to the s= tag in the dkim header.
    # @return [String] selector
    define_option_method :selector

    # @attribute [rw]
    # Header canonicalization algorithm.
    # Valid values are 'simple' and 'relaxed' (default)
    # This corresponds to the first half of the c= tag in the dkim header.
    # @return [String] header canonicalization algorithm
    define_option_method :header_canonicalization

    # @attribute [rw]
    # Body canonicalization algorithm.
    # Valid values are 'simple' and 'relaxed' (default)
    # This corresponds to the second half of the c= tag in the dkim header.
    # @return [String] body canonicalization algorithm
    define_option_method :body_canonicalization

    # @attribute [rw]
    # RSA private key for signing.
    # Can be assigned either an {OpenSSL::PKey::RSA} private key or a valid PEM format string.
    # @return [OpenSSL::PKey::RSA] private key
    define_option_method :private_key
    def private_key= key
      key = OpenSSL::PKey::RSA.new(key) if key.is_a?(String)
      options[:private_key] = key
    end
  end
end
