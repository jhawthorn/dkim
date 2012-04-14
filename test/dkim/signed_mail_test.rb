
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

      # bh value from RFC 6376
      assert_equal '2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8=', dkim_header['bh']
      assert_equal 'mamSUb17FQSZY2lfkeAsH/DvmpHsXdaFAu6BfbVblGBQ5+2yIPCx+clF5wClVBj97utSZb1WwOM0iup1JL37FI/UG+bxHo+MdGLqbLR63THGEdVF8FVeST4o4EQTWe0H3P/sU2rRZ61+M2SrTS94QkKAgj89QNOG48xSAO9xdfs=', dkim_header['b']
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

      assert_equal 'rsa-sha1',                     dkim_header['a']
      assert_equal 'sidney',                       dkim_header['s']
      assert_equal 'example.org',                  dkim_header['d']
      assert_equal 'simple/simple',                dkim_header['c']
      assert_equal 'dns/txt',                      dkim_header['q']
      assert_equal 'yk6W9pJJilr5MMgeEdSd7J3IaJI=', dkim_header['bh']
      assert_equal 'sqYGmen+fouyIj83HuJ1v+1x40xp481bLxxcgAWMFsWYEwG05KYl+o0ZWn8jqgd1coKlX29o9iFjcMtZHudT8KpOdcLVYpY3gxzNfEgH79eRz32/ieGgroSK2GoMA/aV1QkxfUZexLUdj9oOX8uaMYXDkj8RGmlEGi+NDz/e4sE=', dkim_header['b']
    end

    def test_empty_body_hashes
      @mail = @mail.split("\n\n").first + "\n\n"

      # the following are from RFC 6376 section 3.4.3 and 3.4.4
      [
        # [bh, options]
        ['uoq1oCgLlTqpdDX/iUbLy7J1Wic=',                 :body_canonicalization => 'simple',  :signing_algorithm => 'rsa-sha1'],
        ['frcCV1k9oG9oKj3dpUqdJg1PxRT2RSN/XKdLCPjaYaY=', :body_canonicalization => 'simple',  :signing_algorithm => 'rsa-sha256'],
        ['2jmj7l5rSw0yVb/vlWAYkK/YBwk=',                 :body_canonicalization => 'relaxed', :signing_algorithm => 'rsa-sha1'],
        ['47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=', :body_canonicalization => 'relaxed', :signing_algorithm => 'rsa-sha256'],
      ].each do |body_hash, options|
        signed_mail = SignedMail.new(@mail, options)
        dkim_header = signed_mail.dkim_header

        assert_equal body_hash, dkim_header['bh']
      end
    end
  end
end

