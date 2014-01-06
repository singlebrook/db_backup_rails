# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_backup_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "db_backup_rails"
  spec.version       = DbBackupRails::VERSION
  spec.authors       = ["Leon Miller-Out"]
  spec.email         = ["leon@singlebrook.com"]
  spec.description   = %q{Simple gem to back up your database to local storage}
  spec.summary       = %q{Simple gem to back up your database to local storage}
  spec.homepage      = "https://github.com/singlebrook/db_backup_rails"
  spec.license       = "MIT"

  spec.post_install_message = "Thanks for using db_backup_rails! If you have upgraded to 1.x.x from " +
                              "0.x.x, please note that THE DEFAULT BACKUP DIR HAS CHANGED! See the " +
                              "README.md for more info."

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', '> 2.3'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
