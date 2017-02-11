require 'shellwords'

module Reruby
  class FileFinder

    def initialize(config: Config.default)
      @config = config
    end

    def paths_containing_word(word)
      executable = find_executable('ag') || find_executable('ack')
      command = Shellwords.shelljoin([executable, word, "-l", "-G", ruby_extensions_regex])
      paths = paths_from_command(command)
      filter_paths(paths)
    end

    private

    attr_reader :config

    def paths_from_command(command)
      `#{command}`.split("\n")
    end

    def filter_paths(paths)
      if config.get("paths.exclude")
        ignored_regex = paths_regex(config.get("paths.exclude"))
        paths.reject { |path| path =~ ignored_regex }
      else
        paths
      end
    end

    def ruby_extensions_regex
      escaped = config.get("ruby_extensions").map do |extension|
        Regexp.escape(extension)
      end
      /(#{escaped.join("|")})$/
    end

    def paths_regex(path_regexes)
      /#{path_regexes.join("|")}/
    end

    def find_executable(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      return nil
    end


  end
end
