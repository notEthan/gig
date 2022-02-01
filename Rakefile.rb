# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "gig"

Gig.make_task(gemspec_filename: 'gig.gemspec', ignore_files: %w(
  Rakefile.rb
  gig.gemspec
))
