
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
      dkim_header = signed_mail.dkim_header.list

      assert_equal 'rsa-sha1',                        dkim_header['a']
      assert_equal 'sidney',                          dkim_header['s']
      assert_equal 'example.org',                     dkim_header['d']
      assert_equal 'simple/simple',                   dkim_header['c']
      assert_equal 'dns/txt',                         dkim_header['q']
      assert_equal "from:to:subject:date:message-id", dkim_header['h']
      assert_equal 'yk6W9pJJilr5MMgeEdSd7J3IaJI=',    dkim_header['bh']
      assert_equal 't+dk4yxTI2ByZxxRzkwhZhM4WzTZjGWHiWnS2t4pg7oT7fAIlMrfihJ/CIvGmYqYv4lbq4LStHqHx9TmEgxrkjLevHtuqhxkN55xJ2vA2QzTzFi2fMDZ4fFqWy4QtvlLjBAhevG+LXpmjPYec1cyeMlHlPAthq5+RNi6NHErJiM=', dkim_header['b']
    end

    def test_expire
      options = {
        :time => Time.at(1234567890),
        :expire => Time.at(1234567990)
      }
      signed_mail = SignedMail.new(@mail, options)
      dkim_header = signed_mail.dkim_header.list

      assert_equal 1234567990,                                      dkim_header['x']
      assert_equal '2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8=',  dkim_header['bh']
      assert_equal 'dn2Y5rSXQNRBy904vwpvri6xcmlrwKDmDX4XtBgyABQw9jLTulgD/G61TeyqinwgaHiatQaYt4pnpzYQGMaCCg7MepkkpZAR4IggAnHo/qB4JRx5OYBslKCCwpeb70YOPdukVopEnaCoUfkCGJ5vvu3xXG1N+ajKWqYiZ0n4z+o=', dkim_header['b']
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
      assert_equal 'dCiulbJTD+GCCItMij1IU/RO0+q73afdjmrCWV5Qu7BIT5Kbp5Oi3jqCzj/v8Juks2/L6GBSXZia3aZprNVZX0szt8RnwC9NJx9WhcjN2RPz4Zf5F1jJivCN+PtaIWA3i3Ki/DR1q+RuNPgs7T1KKMo3Ih5uHubZIsMwRzbQBc0=', dkim_header['b']
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

