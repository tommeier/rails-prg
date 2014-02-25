# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rails/prg/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-prg"
  spec.version       = Rails::Prg::VERSION
  spec.authors       = ["Tom Meier"]
  spec.email         = ["tom@venombytes.com"]
  spec.summary       = %q{Allow Rails to use full POST-REDIRECT-GET pattern on errors.}
  spec.description   = %q{
    Secure applications must not use browser history or cache, this can cause problems
    with some browsers when following standard Rails pattern for POST -> Error -> Render -> Success -> Redirect.
    For full protection from ERR_CACHE_MISS (in Chrome with no-cache, no-store),
    Rails should redirect on errors as well as on success,
    always following full POST-REDIRECT-GET pattern.
    This way the browser will always have a consistent back-button history to traverse without
    triggering browser errors unable to display form submission pages.
  }
  spec.homepage      = "https://github.com/tommeier/rails-prg"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "actionpack"
  spec.add_dependency "railties"

  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "cane"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "sprockets-rails"
end
