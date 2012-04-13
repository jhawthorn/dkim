require 'test_helper'

require 'mail'

module Dkim
  SIGNEDMAIL = <<-eos
DKIM-Signature: v=1; a=rsa-sha256; s=brisbane; d=example.com;
      c=simple/simple; q=dns/txt; i=joe@football.example.com;
      h=Received : From : To : Subject : Date : Message-ID;
      bh=2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8=;
      b=AuUoFEfDxTDkHlLXSZEpZj79LICEps6eda7W3deTVFOk4yAUoqOB
        4nujc7YopdG5dWLSdNg6xNAZpOPr+kHxt1IrE+NahM6L/LbvaHut
        KVdkLLkpVaVVQPzeRDI009SO2Il5Lu7rDNH6mZckBdrIx0orEtZV
        4bmp/YzhwvcubU4=;
Received: from client1.football.example.com  [192.0.2.1]
      by submitserver.example.com with SUBMISSION;
      Fri, 11 Jul 2003 21:01:54 -0700 (PDT)
From: Joe SixPack <joe@football.example.com>
To: Suzie Q <suzie@shopping.example.net>
Subject: Is dinner ready?
Date: Fri, 11 Jul 2003 21:00:37 -0700 (PDT)
Message-ID: <20030712040037.46341.5F8J@football.example.com>
DKIM-Signature: v=1; a=rsa-sha256; s=brisbane; d=example.com;
      c=simple/simple; q=dns/txt; i=joe@football.example.com;
      h=Received : From : To : Subject : Date : Message-ID;
      bh=2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8=;
      b=AuUoFEfDxTDkHlLXSZEpZj79LICEps6eda7W3deTVFOk4yAUoqOB
        4nujc7YopdG5dWLSdNg6xNAZpOPr+kHxt1IrE+NahM6L/LbvaHut
        KVdkLLkpVaVVQPzeRDI009SO2Il5Lu7rDNH6mZckBdrIx0orEtZV
        4bmp/YzhwvcubU4=;

Hi.

We lost the game. Are you hungry yet?

Joe.
  eos

  class InterceptorTest < MiniTest::Unit::TestCase
    def setup
      @original_options = Dkim.options.dup

      mail = EXAMPLEEMAIL.dup

      @mail = Mail.new(mail)
    end

    def teardown
      Dkim.options = @original_options
    end

    def test_header_with_relaxed
      Dkim.header_canonicalization = 'relaxed'
      Dkim.body_canonicalization = 'relaxed'
      Dkim.signing_algorithm = 'rsa-sha256'
      Interceptor.delivering_email(@mail)
      dkim_header = @mail['DKIM-Signature']

      assert dkim_header
      assert_includes dkim_header.to_s, 'rsa-sha256'
      assert_includes dkim_header.to_s, 's=brisbane'
      assert_includes dkim_header.to_s, 'd=example.com'
      assert_includes dkim_header.to_s, 'c=relaxed/relaxed'
      assert_includes dkim_header.to_s, 'q=dns/txt'
      assert_includes dkim_header.to_s, 'bh=2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8='

      # TODO: double check signing of 'b' header
    end

    def test_header_with_relaxed
      Dkim.header_canonicalization = 'simple'
      Dkim.body_canonicalization = 'simple'
      Dkim.signing_algorithm = 'rsa-sha256'
      Interceptor.delivering_email(@mail)
      dkim_header = @mail['DKIM-Signature']
      assert dkim_header
      assert_includes dkim_header.to_s, 'rsa-sha256'
      assert_includes dkim_header.to_s, 's=brisbane'
      assert_includes dkim_header.to_s, 'd=example.com'
      assert_includes dkim_header.to_s, 'c=simple/simple'
      assert_includes dkim_header.to_s, 'q=dns/txt'
      assert_includes dkim_header.to_s, 'bh=2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8='

      # TODO: double check signing of 'b' header
    end

    def test_strips_exsting_headers
      warnings = ""
      klass = Class.new(Interceptor)
      klass.class.send(:define_method, :warn) do |message|
        warnings << message << "\n"
      end
      @mail = Mail.new(SIGNEDMAIL)

      assert_equal 2, @mail.header.fields.count { |field| field.name =~ /^DKIM-Signature$/i }
      assert_equal 2, @mail.encoded.scan('DKIM-Signature').count

      klass.delivering_email(@mail)

      # should give a warning
      assert_includes warnings, 'Interceptor'

      assert_equal 1, @mail.header.fields.count { |field| field.name =~ /^DKIM-Signature$/i }
      assert_equal 1, @mail.encoded.scan('DKIM-Signature').count
    end
  end
end

