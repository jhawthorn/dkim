
require 'test_helper'
require 'base64'

module Dkim
  class DkimHeaderTest < Minitest::Test
    def setup
      @header = DkimHeader.new

      # from Appendix A of RFC 6376
      @header['v'] = '1'
      @header['a'] = 'rsa-sha256'
      @header['s'] = 'brisbane'
      @header['d'] = 'example.com'
      @header['c'] = 'simple/simple'
      @header['q'] = 'dns/txt'
      @header['i'] = 'joe@football.example.com'
      @header['h'] = 'Received : From : To : Subject : Date : Message-ID'
      @header['bh']= Base64.decode64 '2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8='
      @header['b'] = Base64.decode64 'AuUoFEfDxTDkHlLXSZEpZj79LICEps6eda7W3deTVFOk4yAUoqOB4nujc7YopdG5dWLSdNg6xNAZpOPr+kHxt1IrE+NahM6L/LbvaHutKVdkLLkpVaVVQPzeRDI009SO2Il5Lu7rDNH6mZckBdrIx0orEtZV4bmp/YzhwvcubU4='
    end

    def test_correct_format
      header = @header.to_s

      # result from RFC 6376 minus trailing ';'
      expected = %{
   DKIM-Signature: v=1; a=rsa-sha256; s=brisbane; d=example.com;
         c=simple/simple; q=dns/txt; i=joe@football.example.com;
         h=Received : From : To : Subject : Date : Message-ID;
         bh=2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8=;
         b=AuUoFEfDxTDkHlLXSZEpZj79LICEps6eda7W3deTVFOk4yAUoqOB
           4nujc7YopdG5dWLSdNg6xNAZpOPr+kHxt1IrE+NahM6L/LbvaHut
           KVdkLLkpVaVVQPzeRDI009SO2Il5Lu7rDNH6mZckBdrIx0orEtZV
           4bmp/YzhwvcubU4=
      }

      # compare removing whitespace
      assert_equal expected.gsub(/\s/,''), header.gsub(/\s/,'')
    end
  end
end

