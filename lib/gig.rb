# frozen_string_literal: true

require 'gig/version'

module Gig
  class << self
    # @param name [#to_s] rake task name
    # @param gemspec_filename
    # @param ignore_files [Enumerable<String>]
    def make_task(name: 'gig', gemspec_filename: , ignore_files: )
      Rake.application.last_description = "check consistency of gemspec files with git and filesystem before building the gem"
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
          in_ignore = ignore_files.include?(file)

          if in_spec
            if in_ignore
              file_error.("file in gig ignore_files, but present in gemspec: #{file}")
            end

            if in_git
              if in_fs
                git_status = `git status --porcelain #{Shellwords.escape(file)}`
                if git_status.empty?
                  # pass
                else
                  file_error.("file in gemspec, but modified from git: #{file}")
                end
              else
                file_error.("file in gemspec, but not in filesystem: #{file}")
              end
            else
              if in_fs
                file_error.("file in gemspec and filesystem, but not in git: #{file}")
              else
                file_error.("file in gemspec, but not in git and not in filesystem: #{file}")
              end
            end
          elsif in_ignore
            # in ignore_files, and not in gemspec: pass (regardless of git or fs)
          else
            if in_git
              file_error.("file in git, but in neither gemspec nor gig ignore_files: #{file}")
            else
              # not in gemspec, not in ignore_files, not in git: pass - it's in the filesystem but can be ignored
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
