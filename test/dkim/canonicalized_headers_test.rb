
require 'test_helper'

module Dkim
  class CanonicalizedHeadersTest < MiniTest::Unit::TestCase
    def test_maintains_order
      headers = "ABCD".chars.map {|c| Header.new(c, c) }
      header_keys = headers.map &:relaxed_key
      header_keys.permutation.each do |signed_headers|
        ch = CanonicalizedHeaders.new(headers, signed_headers)
        assert_equal signed_headers, ch.map(&:relaxed_key)
      end
    end

    def test_repeated_headers
      headers = [
        Header.new('A', '1'),
        Header.new('B', '2'),
        Header.new('C', '3'),
        Header.new('A', '4'),
        Header.new('D', '5')
      ]
      ch = CanonicalizedHeaders.new(headers, %w{A A B C D})
      assert_equal %w{4 1 2 3 5}, ch.map(&:value)
      assert_equal <<-eos.rfc_format, ch.to_s('simple')
      A:4<CRLF>
      A:1<CRLF>
      B:2<CRLF>
      C:3<CRLF>
      D:5<CRLF>
      eos
    end

    # missing headers should be ignored
    def test_missing_headers
      headers = [
        Header.new('A', '1'),
        Header.new('B', '2'),
        Header.new('C', '3'),
      ]
      ch = CanonicalizedHeaders.new(headers, %w{A A B C})
      assert_equal %w{a b c}, ch.map(&:relaxed_key)
      assert_equal <<-eos.rfc_format, ch.to_s('simple')
      A:1<CRLF>
      B:2<CRLF>
      C:3<CRLF>
      eos
    end
  end
end

