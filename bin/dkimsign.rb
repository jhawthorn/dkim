#!/usr/bin/ruby

if ARGV.length != 2 && ARGV.length != 3
  puts "Usage: dkimsign.rb DOMAIN SELECTOR KEYFILE [MAILFILE]"
  exit 0
end

require 'dkim'

domain, selector, keyfile, mailfile = ARGV

keyfile  = File.open(keyfile)
mailfile = mailfile ? File.open(mailfile) : STDIN

mail = mailfile.read.gsub(/\r?\n/, "\r\n")
key  = keyfile.read

Dkim::domain = domain
Dkim::selector = selector
Dkim::private_key = key

print Dkim::SignedMail.new(mail).to_s


