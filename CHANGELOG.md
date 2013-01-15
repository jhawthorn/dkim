# dkim Changelog

## 1.0.0 (2012-01-15)
* DKIM-Signature header is now prepended rather than appended
* Headers are signed in the order they appear
* Correct signing of repeated headers
* Correct signing of missing headers

## 0.2.0 (2012-04-15)
* Warn and strip existing signatures in Dkim::Interceptor
* Dkim options can be accessed and modified using new Dkim.options or signed_mail.options hash
* Refactoring and better testing
* Improved documentation

## 0.1.0 (2011-12-10)
* Ensure header lines are not folded using Dkim::Interceptor

## 0.0.3 (2011-07-25)
* add Dkim::Interceptor class for integration with rails and [mail](https://github.com/mikel/mail)

## 0.0.2 (2011-06-01)

* add convenience method Dkim.sign
* support for the simple canonicalization algorithm
* domain now must be specified as an option
* correct handling of an empty message body


## 0.0.1 (2011-05-10)

* Initial release

