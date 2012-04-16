# dkim Changelog

## 2012.04.15, Version 0.2.0
* Warn and strip existing signatures in Dkim::Interceptor
* Dkim options can be accessed and modified using new Dkim.options or signed_mail.options hash
* Refactoring and better testing
* Improved documentation

## 2011.12.10, Version 0.1.0
* Ensure header lines are not folded using Dkim::Interceptor

## 2011.07.25, Version 0.0.3
* add Dkim::Interceptor class for integration with rails and [mail](https://github.com/mikel/mail)

## 2011.06.01, Version 0.0.2

* add convenience method Dkim.sign
* support for the simple canonicalization algorithm
* domain now must be specified as an option
* correct handling of an empty message body


## 2011.05.10, Version 0.0.1

* Initial release

