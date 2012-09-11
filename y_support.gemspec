# -*- encoding: utf-8 -*-
require File.expand_path('../lib/y_support/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["boris"]
  gem.email         = ["\"boris@iis.sinica.edu.tw\""]
  gem.description   = %q{A collection of extensions used by y_... gems.}
  gem.summary       = %q{LocalObject, RespondTo, InertRecorder, NullObject, experimental extensions to Object, Module, Enumerable, Array, Hash, String, Symbol, Matrix, Vector, plus requires of YUnicode, YScrupples and ActiveSupport methods.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "y_support"
  gem.require_paths = ["lib"]
  gem.version       = YSupport::VERSION
  
  gem.add_dependency "activesupport"
  gem.add_development_dependency "shoulda"
end
