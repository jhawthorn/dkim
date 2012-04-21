
require 'test_helper'

module Dkim
  class CanonicalizedHeadersTest < MiniTest::Unit::TestCase
    def test_maintains_order
      headers = "ABCDEFG".chars.map {|c| Header.new(c, c) }
      header_keys = headers.map &:relaxed_key
      header_keys.permutation.each do |signed_headers|
        ch = CanonicalizedHeaders.new(headers, signed_headers)
        assert_equal signed_headers, ch.map(&:relaxed_key)
      end
    end
  end
end

