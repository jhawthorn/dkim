
require 'test_helper'

module Dkim
  class CanonicalizationTest < MiniTest::Unit::TestCase
    # from section 3.4.6 of RFC 6376
    def setup
      @input = <<-eos.rfc_format
      A: <SP> X <CRLF>
      B <SP> : <SP> Y <HTAB><CRLF>
      <HTAB> Z <SP><SP><CRLF>
      <CRLF>
      <SP> C <SP><CRLF>
      D <SP><HTAB><SP> E <CRLF>
      <CRLF>
      <CRLF>
      eos
      @mail = SignedMail.new(@input)
      @mail.signable_headers = ['A', 'B']
    end
    def test_relaxed_header
      @mail.header_canonicalization = 'relaxed'
      expected_header = <<-eos.rfc_format
      a:X <CRLF>
      b:Y <SP> Z <CRLF>
      eos
      assert_equal expected_header, @mail.canonical_header
    end
    def test_relaxed_body
      @mail.body_canonicalization = 'relaxed'
      expected_body = <<-eos.rfc_format
      <SP> C <CRLF>
      D <SP> E <CRLF>
      eos
      assert_equal expected_body, @mail.canonical_body
    end

    def test_simple_header
      @mail.header_canonicalization = 'simple'
      expected_header = <<-eos.rfc_format
      A: <SP> X <CRLF>
      B <SP> : <SP> Y <HTAB><CRLF>
      <HTAB> Z <SP><SP><CRLF>
      eos
      assert_equal expected_header, @mail.canonical_header
    end
    def test_simple_body
      @mail.body_canonicalization = 'simple'
      expected_body = <<-eos.rfc_format
      <SP> C <SP><CRLF>
      D <SP><HTAB><SP> E <CRLF>
      eos
      assert_equal expected_body, @mail.canonical_body
    end

    # from errata: empty bodies
    def test_simple_empty_body
      @mail = SignedMail.new("test: test\r\n\r\n")
      @mail.body_canonicalization = 'simple'

      assert_equal "\r\n", @mail.canonical_body
    end

    def test_relaxed_empty_body
      @mail = SignedMail.new("test: test\r\n\r\n")
      @mail.body_canonicalization = 'relaxed'

      assert_equal "", @mail.canonical_body
    end

    def test_relaxed_errata_1384
      body = "testing<crlf><sp><sp><cr><lf><cr><lf>".rfc_format
      @mail = SignedMail.new("test: test\r\n\r\n#{body}")
      @mail.body_canonicalization = 'relaxed'

      assert_equal "testing\r\n", @mail.canonical_body
    end
  end
end

