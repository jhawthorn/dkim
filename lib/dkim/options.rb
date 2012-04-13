module Dkim
  module Options
    ATTRIBUTES = :time, :private_key, :signing_algorithm, :signable_headers, :domain, :selector, :time, :header_canonicalization, :body_canonicalization
    def options
      @options ||= {}
    end
    attr_writer :options

    ATTRIBUTES.each do |attribute_name|
      define_method(attribute_name){options[attribute_name]}
      define_method("#{attribute_name}="){|value| options[attribute_name] = value}
    end

    def private_key= key
      key = OpenSSL::PKey::RSA.new(key) if key.is_a?(String)
      options[:private_key] = key
    end
  end
end
