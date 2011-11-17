# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simpex/version"

Gem::Specification.new do |s|
  s.name        = "simpex"
  s.version     = Simpex::VERSION
  s.authors     = ["Denis Lutz"]
  s.email       = ["denis.lutz@gmail.com"]
  s.homepage    = "https://github.com/denislutz/simpex"
  s.summary     = %q{Simpex is gem to confortably create hybris impex format files in an object oriented way.}
  s.description = %q{Read more details at the homepage https://github.com/denislutz/simpex}

  s.rubyforge_project = "simpex"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

