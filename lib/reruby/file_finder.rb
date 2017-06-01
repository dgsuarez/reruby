require 'shellwords'

module Reruby
  class FileFinder

    def initialize(config: Config.default)
      @config = config
    end

    def paths_containing_word(word)
      paths = paths_from_command(command(word))
      filter_paths(paths)
    end

    private

    attr_reader :config

    def command(word)
      Shellwords.shelljoin([executable, word, "-l", "-g",
                            ruby_extensions_regex])
    end

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

    def executable
      "rak"
    end

  end
end
