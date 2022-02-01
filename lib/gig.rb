# frozen_string_literal: true

require 'gig/version'

module Gig
  class << self
    # @param name [#to_s] rake task name
    # @param gemspec_filename
    # @param ignore_files [Enumerable]
    def make_task(name: 'gig', gemspec_filename: , ignore_files: )
      Rake::Task.define_task(name) do
        require 'shellwords'
        require 'set'

        git_files = `git ls-files -z --recurse-submodules`.split("\x0")

        fs_files = Dir.glob('**/*', File::FNM_DOTMATCH).reject { |f| File.lstat(f).ftype == 'directory' }

        spec = Gem::Specification.load(gemspec_filename) || abort("gemspec did not load: #{gemspec_filename}")

        files = Set.new + git_files + fs_files + spec.files + spec.test_files

        file_errors = []
        file_error = -> (msg) {
          file_errors << msg
          puts msg
        }

        files.each do |file|
          in_git = git_files.include?(file)
          in_fs = fs_files.include?(file)
          in_spec = spec.files.include?(file) || spec.test_files.include?(file)

          if in_git
            if in_fs
              if in_spec
                git_status = `git status --porcelain #{Shellwords.escape(file)}`
                if git_status.empty?
                  # pass
                else
                  file_error.("file modified from git: #{file}")
                end
              else
                if ignore_files.include?(file)
                  # pass
                else
                  file_error.("git file not in gemspec: #{file}")
                end
              end
            else
              file_error.("git file not in fs: #{file}")
            end
          else
            if in_spec
              file_error.("file in gemspec but not in git: #{file}")
            else
              # in fs but ignored by git and spec: pass
            end
          end
        end

        unless file_errors.empty?
          abort "aborting gem build due to file errors"
        end

        require 'rubygems/package'
        Gem::Package.build(spec)
      end
    end
  end
end
