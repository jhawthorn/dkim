#!/usr/bin/ruby

if ARGV.length != 2 && ARGV.length != 3
  puts "Usage: dkimsign.rb SELECTOR KEYFILE [MAILFILE]"
  exit 0
end

selector, keyfile,mailfile = ARGV

keyfile = File.open(keyfile)
mailfile = mailfile ? File.open(mailfile) : STDIN

