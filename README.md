`gig` contains a rake task of the same name to check for consistency of files between git, gemspec, and the filesystem before building.

## Usage

In your rakefile, `require 'gig'` and invoke [Gig.make_task](https://rubydoc.info/gems/gig/Gig), passing `gemspec_filename` and `ignore_files`. Globs are useful for `ignore_files`, and `File::FNM_DOTMATCH` should be used when globs may contain dotfiles. For example:

```ruby
require 'gig'

ignore_files = %w(
  .github/**/*
  .gitignore
  .gitmodules
  Gemfile
  Rakefile.rb
  test/**/*
).map { |glob| Dir.glob(glob, File::FNM_DOTMATCH) }.inject([], &:|)
Gig.make_task(gemspec_filename: 'my_gem.gemspec', ignore_files: ignore_files)
```

## License

The gem is available under the terms of the [MIT License](https://opensource.org/licenses/MIT).
