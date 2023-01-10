# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gig/version"

Gem::Specification.new do |spec|
  spec.name    = "gig"
  spec.version = Gig::VERSION
  spec.authors = ["Ethan"]
  spec.email   = ["ethan@unth.net"]

  spec.summary     = "gig"
  spec.description = "a rake task to check a gem's consistency with git and the filesystem before building"
  spec.homepage    = "https://github.com/notEthan/gig"
  spec.license     = "MIT"

  spec.files = [
    'LICENSE.txt',
    'README.md',
    *Dir['lib/**/*'],
  ].reject { |f| File.lstat(f).ftype == 'directory' }

  spec.require_paths = ["lib"]

  spec.add_dependency 'rake'
end
