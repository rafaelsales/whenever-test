# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'whenever-test'
  spec.version       = '1.0.0'
  spec.authors       = ['Rafael Sales']
  spec.email         = ['rafaelcds@gmail.com']
  spec.summary       = %q{Test Whenever scheduled jobs}
  spec.description   = %q{Whenever gem doesn't provide test support, so whenever-test makes that possible}
  spec.homepage      = 'https://github.com/heartbits/whenever-test'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'whenever'
end
