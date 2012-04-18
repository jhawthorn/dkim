
require 'test_helper'

module Dkim
  class SignedMailTest < MiniTest::Unit::TestCase
    def setup
      @mail = EXAMPLEEMAIL.dup
    end

    def test_defaults
      signed_mail = SignedMail.new(@mail, :time => Time.at(1234567890))
      dkim_header = signed_mail.dkim_header

      assert_equal 'rsa-sha256',                                   dkim_header['a']
      assert_equal 'brisbane',                                     dkim_header['s']
      assert_equal 'example.com',                                  dkim_header['d']
      assert_equal 'relaxed/relaxed',                              dkim_header['c']
      assert_equal 'dns/txt',                                      dkim_header['q']
      assert_equal 'from:to:subject:date:message-id',              dkim_header['h']

      # bh value from RFC 6376
      assert_equal '2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8=', dkim_header['bh']
      assert_equal 'dQOeSpGJTfSbX4hPGGsy4ipcNAzC/33K7XaEXkjBneJJhv6MczHkJNsfmXeYESNIh5WVTuvE5IbnDPBVFrL+b3GKiLiyp/vlKO2NJViX4dLnKT/GdxjJh06ljZcYjUA+PorHvMwdu+cDsCffN8A7IhfVdsFruQr3vFPD0JyJ9XU=', dkim_header['b']
    end

    def test_overrides
      options = {
        :domain => 'example.org',
        :selector => 'sidney',
        :time => Time.now,
        :signing_algorithm => 'rsa-sha1',
        :header_canonicalization => 'simple',
        :body_canonicalization => 'simple',
        :time => Time.at(1234567890)
      }
      signed_mail = SignedMail.new(@mail, options)
      dkim_header = signed_mail.dkim_header

      assert_equal 'rsa-sha1',                        dkim_header['a']
      assert_equal 'sidney',                          dkim_header['s']
      assert_equal 'example.org',                     dkim_header['d']
      assert_equal 'simple/simple',                   dkim_header['c']
      assert_equal 'dns/txt',                         dkim_header['q']
      assert_equal "from:to:subject:date:message-id", dkim_header['h']
      assert_equal 'yk6W9pJJilr5MMgeEdSd7J3IaJI=',    dkim_header['bh']
      assert_equal 't+dk4yxTI2ByZxxRzkwhZhM4WzTZjGWHiWnS2t4pg7oT7fAIlMrfihJ/CIvGmYqYv4lbq4LStHqHx9TmEgxrkjLevHtuqhxkN55xJ2vA2QzTzFi2fMDZ4fFqWy4QtvlLjBAhevG+LXpmjPYec1cyeMlHlPAthq5+RNi6NHErJiM=', dkim_header['b']
    end

    def test_empty_body_hashes
      @mail = @mail.split("\n\n").first + "\n\n"

      # the following are from RFC 6376 section 3.4.3 and 3.4.4
      [
        # [bh, options]
        ['uoq1oCgLlTqpdDX/iUbLy7J1Wic=',                 {:body_canonicalization => 'simple',  :signing_algorithm => 'rsa-sha1'  }],
        ['frcCV1k9oG9oKj3dpUqdJg1PxRT2RSN/XKdLCPjaYaY=', {:body_canonicalization => 'simple',  :signing_algorithm => 'rsa-sha256'}],
        ['2jmj7l5rSw0yVb/vlWAYkK/YBwk=',                 {:body_canonicalization => 'relaxed', :signing_algorithm => 'rsa-sha1'  }],
        ['47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=', {:body_canonicalization => 'relaxed', :signing_algorithm => 'rsa-sha256'}],
      ].each do |body_hash, options|
        signed_mail = SignedMail.new(@mail, options)
        dkim_header = signed_mail.dkim_header

        assert_equal body_hash, dkim_header['bh']
      end
    end
  end
end

