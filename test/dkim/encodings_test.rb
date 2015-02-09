module Dkim
  class EncodingsTest < Minitest::Test
    def test_plain_text
      @encoder = Encodings::PlainText.new
      assert_equal 'testing123', @encoder.encode('testing123')
      assert_equal 'testing123', @encoder.decode('testing123')
    end
    def test_base64
      @encoder = Encodings::Base64.new
      assert_equal 'dGVzdGluZzEyMw==', @encoder.encode('testing123')
      assert_equal 'testing123',       @encoder.decode('dGVzdGluZzEyMw==')
    end
    def test_quoted_printable
      @encoder = Encodings::DkimQuotedPrintable.new
      assert_equal 'testing123', @encoder.encode('testing123')
      assert_equal 'testing123', @encoder.decode('testing123')

      encoded = 'From:foo@eng.example.net|To:joe@example.com|Subject:demo=20run|Date:July=205,=202005=203:44:08=20PM=20-0700'
      decoded = 'From:foo@eng.example.net|To:joe@example.com|Subject:demo run|Date:July 5, 2005 3:44:08 PM -0700'
      assert_equal encoded, @encoder.encode(decoded)
      assert_equal decoded, @encoder.decode(encoded)
    end
  end
end
