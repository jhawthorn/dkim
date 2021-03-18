
require 'test_helper'

module Dkim
  class SignedMailTest < Minitest::Test
    def setup
      @mail = EXAMPLEEMAIL.dup
    end

    def test_defaults
      signed_mail = SignedMail.new(@mail, :time => Time.at(1234567890))
      dkim_header = signed_mail.dkim_header.list

      assert_equal 'rsa-sha256',                                   dkim_header['a']
      assert_equal 'brisbane',                                     dkim_header['s']
      assert_equal 'example.com',                                  dkim_header['d']
      assert_equal 'relaxed/relaxed',                              dkim_header['c']
      assert_equal 'dns/txt',                                      dkim_header['q']
      assert_equal 'from:to:subject:date:message-id',              dkim_header['h']

      # bh value from RFC 6376
      assert_equal '2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8=', dkim_header['bh']
      assert_equal 'QppIlbEcMAX4axIDBcTDYmr5UMS+qZygn6pcHzxw5glhBU0rDMy2bAPN1SqaQnx8pnpbaVtvS5YpkzYf5HOSARRZKerKat1XiN1MHrZzSL7gBUdDU++uGVcqq/CS8sEfUKBQtbAdWychFUx0EkPZrDJdYQZy/UEd+mx1UY4GNY4=', dkim_header['b']
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
      dkim_header = signed_mail.dkim_header.list

      assert_equal 'rsa-sha1',                        dkim_header['a']
      assert_equal 'sidney',                          dkim_header['s']
      assert_equal 'example.org',                     dkim_header['d']
      assert_equal 'simple/simple',                   dkim_header['c']
      assert_equal 'dns/txt',                         dkim_header['q']
      assert_equal "from:to:subject:date:message-id", dkim_header['h']
      assert_equal 'yk6W9pJJilr5MMgeEdSd7J3IaJI=',    dkim_header['bh']
      assert_equal 'iDzlYPN071tQNcjQHle367n+1ZxnipOr5J3GPj/SUrKgDUXqF7r65Uf23FZMMibYgC3uXZgRFgXrRObBfccJpCgEqp/B8P/mI4jGc3EMuVLUiMrx79beZQOe7a0vSJNwBsqu7fkz1UWp5o2DXT8anUNixV41+37aRakAB5ChYSU=', dkim_header['b']
    end

    def test_identity
      options = {
        :domain => 'example.org',
        :selector => 'sidney',
        :identity => '@example.org',
        :time => Time.at(1234567890)
      }
      signed_mail = SignedMail.new(@mail, options)
      dkim_header = signed_mail.dkim_header.list

      assert_equal '@example.org',                                  dkim_header['i']
      assert_equal '2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8=',  dkim_header['bh']
      assert_equal 'E+b3dktXUAexSXidTLU6CDLLHgdyWkED27uPqGgYpQadOYrc+JcbdWCqzA4oqrtz5rs0Cjxh6X7AxpjU2xHY2kURkDozNoNMnrilg3Pw2lfpPt6yjP34O8vjnWsiRQBqfeXZ7BDWstPjmXJcjCUnOg9bf1y03jFDuzwHKZSYYNg=', dkim_header['b']
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
        dkim_header = signed_mail.dkim_header.list

        assert_equal body_hash, dkim_header['bh']
      end
    end

    def test_multiple_instances_of_header
      @mail = <<-eos
Received: <A>
Received: <B>
Received: <C>

      eos

      signed_mail = SignedMail.new(@mail, :header_canonicalization => 'simple', :signable_headers => Dkim::DefaultHeaders + ['Received'])

      assert_equal "received:received:received", signed_mail.dkim_header['h']

      headers = signed_mail.canonical_header
      assert_equal "Received: <C>\r\nReceived: <B>\r\nReceived: <A>\r\n", headers.to_s
    end
  end
end
