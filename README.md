dkim
====
[![Build Status](https://secure.travis-ci.org/jhawthorn/dkim.png?branch=master)](http://travis-ci.org/jhawthorn/dkim)

A DKIM signing library in ruby.

Installation
============

    sudo gem install dkim

Usage
=====

Calling `Dkim.sign` on a string representing an email message returns the message with a DKIM signature inserted.

For example

    mail = <<eos
    To: someone@example.com
    From: john@example.com
    Subject: hi
    
    Howdy
    eos

    Dkim.sign(mail)

    # =>
    # To: someone@example.com
    # From: john@example.com
    # Subject: hi
    # DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=example.com; q=dns/txt; s=mail; t=1305917829;
    #  	bh=qZxwTnSM1ywsrq0Ag9UhQSOtVIG+sW5zDkB+hPbuX08=; h=from:subject:to;
    #  	b=0mKnNOkxFGiww63Zu4t46J7eZc3Uak3I9km3IH2Le3XcnSNtWJgxiwBX26IZ5yzcT
    # 	VwJzcCnPKCScIJMQ7yfbfXmNsKVIOV6eSUqu1YvJ1fgzlSAXuDEMNFTjoto5rrdA+
    # 	BgX849hEY/bWHDl1JJgNpiwtpl4t0Q7M4BVJUd7Lo=
    # 
    # Howdy

Necessary configuration
-----------------------
A private key, a domain, and a selector need to be specified in order to sign messages.

These can be specified globally

    Dkim::domain      = 'example.com'
    Dkim::selector    = 'mail'
    Dkim::private_key = open('private.pem').read

Options can be overridden per message.

    Dkim.sign(mail, :selector => 'mail2', :private_key => open('private2.pem').read)

Additional configuration
------------------------

The following is the default configuration

    Dkim::signable_headers        = Dkim::DefaultHeaders # Sign only the specified headers
    Dkim::signing_algorithm       = 'rsa-sha256' # can be rsa-sha1 or rsa-sha256 (default)
    Dkim::header_canonicalization = 'relaxed'    # Can be simple or relaxed (default)
    Dkim::body_canonicalization   = 'relaxed'    # Can be simple or relaxed (default)

The defaults should fit most users needs; however, certain use cases will need them to be customized.

For example, for sending mesages through amazon SES, certain headers should not be signed

    Dkim::signable_headers = Dkim::DefaultHeaders - %w{Message-ID Resent-Message-ID Date Return-Path Bounces-To}

RFC 6376 states that signers SHOULD sign using rsa-sha256. For this reason, dkim will *not* use rsa-sha1 as a fallback if the openssl library does not support sha256.
If you wish to override this behaviour and use whichever algorithm is available you can use this snippet (**not recommended**).

    Dkim::signing_algorithm = defined?(OpenSSL::Digest::SHA256) ? 'rsa-sha256' : 'rsa-sha1'

Usage With Rails
================

Dkim contains `Dkim::Interceptor` which can be used to sign all mail delivered by the [mail gem](https://github.com/mikel/mail) or rails 3, which uses mail.
For rails, create an initializer (for example `config/initializers/dkim.rb`) with the following template.

    # Configure dkim globally (see above)
    Dkim::domain      = 'example.com'
    Dkim::selector    = 'mail'
    Dkim::private_key = open('private.pem').read

    # This will sign all ActionMailer deliveries
    ActionMailer::Base.register_interceptor(Dkim::Interceptor)

Example executable
==================

The library includes a `dkimsign.rb` executable suitable for testing the library or performing simple signatures.

`dkimsign.rb DOMAIN SELECTOR KEYFILE [MAILFILE]`

If MAILFILE is not specified `dkimsign.rb` will read the mail message from standard in.

Limitations
===========

* Strictly a DKIM signing library. No support for signature verification. *(none planned)*
* No support for the older Yahoo! DomainKeys standard ([RFC 4870](http://tools.ietf.org/html/rfc4870)) *(none planned)*
* No support for specifying DKIM identity `i=` *(planned)*
* No support for body length `l=` *(planned)*
* No support for signature expiration `x=` *(planned)*
* No support for copied header fields `z=` *(not immediately planned)*

Resources
=========

* [RFC 6376](http://tools.ietf.org/html/rfc6376)
* Inspired by perl's [Mail-DKIM](http://dkimproxy.sourceforge.net/)

Copyright
=========

(The MIT License)

Copyright (c) 2011 [John Hawthorn](http://www.johnhawthorn.com/)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
