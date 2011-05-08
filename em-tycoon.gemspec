# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "em-tycoon"
  s.version     = "0.9.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Ingrassia"]
  s.email       = ["chris@noneofyo.biz"]
  s.homepage    = "http://github.com/andry1/em-tycoon"
  s.summary     = %q{EventMachine client for Kyoto Tycoon}
  s.description = %q{An async client for Kyoto Tycoon's binary protocol using EventMachine}

  s.rubyforge_project = "em-tycoon"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency(%q<eventmachine>, [">= 0"])
end
