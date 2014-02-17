# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dkim/version"

Gem::Specification.new do |s|
  s.name        = "dkim"
  s.version     = Dkim::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Hawthorn"]
  s.email       = ["john.hawthorn@gmail.com"]
  s.homepage    = "https://github.com/jhawthorn/dkim"
  s.summary     = %q{DKIM library in ruby}
  s.description = %q{gem for adding DKIM signatures to email messages}

  s.rubyforge_project = "dkim"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'awesome_print'
end
