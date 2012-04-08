require 'test_helper'

require 'mail'

class DkimInterceptorTest < Test::Unit::TestCase
  def setup
    mail = EXAMPLEEMAIL.dup

    Dkim::selector = 'brisbane'
    @mail = Mail.new(mail)
  end

  def teardown
    Dkim::selector = nil
  end

  def test_header_with_relaxed
    Dkim.header_canonicalization = 'relaxed'
    Dkim.body_canonicalization = 'relaxed'
    Dkim.signing_algorithm = 'rsa-sha256'
    Dkim::Interceptor.delivering_email(@mail)
    dkim_header = @mail['Dkim-Signature']
    assert_not_nil dkim_header
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
    Dkim::Interceptor.delivering_email(@mail)
    dkim_header = @mail['Dkim-Signature']
    assert_not_nil dkim_header
    assert_includes dkim_header.to_s, 'rsa-sha256'
    assert_includes dkim_header.to_s, 's=brisbane'
    assert_includes dkim_header.to_s, 'd=example.com'
    assert_includes dkim_header.to_s, 'c=simple/simple'
    assert_includes dkim_header.to_s, 'q=dns/txt'
    assert_includes dkim_header.to_s, 'bh=2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8='

    # TODO: double check signing of 'b' header
  end
end

