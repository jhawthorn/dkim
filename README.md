dkim
====

A DKIM signing library in ruby.

Installation
============

    sudo gem install dkim

Usage
=====

Calling `Dkim.sign` on a string representing an email message returns the message with a dkim signature inserted.

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
The dkim needs a private key, a domain, and a selector specified in order to sign messages.

These can be specified globally

    Dkim::domain      = 'example.com'
    Dkim::selector    = 'mail'
    Dkim::private_key = open('private.pem').read

or overridden per message

    Dkim.sign(mail, :selector => 'mail2', :private_key => open('private2.pem').read)

Additional configuration
------------------------

    Dkim::signable_headers        = Dkim::DefaultHeaders - ['Time'] # don't sign the time header
    Dkim::signing_algorithm       = 'rsa-sha1' # can be rsa-sha1 or rsa-sha256 (default)
    Dkim::header_canonicalization = 'simple'   # Can be simple or relaxed (default)
    Dkim::body_canonicalization   = 'simple'   # Can be simple or relaxed (default)

Example executable
==================

The library includes the `dkimsign.rb` executable

   Usage: dkimsign.rb DOMAIN SELECTOR KEYFILE [MAILFILE]

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
