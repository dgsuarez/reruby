require 'shellwords'

module Reruby
  class FileFinder

    def initialize(config: Config.default)
      @config = config
    end

    def paths_containing_word(word)
      paths = all_paths_containing(word)
      filter_paths(paths)
    end

    private

    attr_reader :config

    def executable_wrapper
      wrapper = [AgWrapper, FindGrepWrapper].detect(&:available?)
      wrapper.new(config.get("ruby_extensions"))
    end

    def all_paths_containing(word)
      command = executable_wrapper.command(word)
      paths = `#{command}`.split("\n")
      paths.map { |path| path.sub(%r{^\./}, '') }
    end

    def filter_paths(paths)
      excluded_paths = config.get("paths.exclude")
      if excluded_paths
        ignored_regex = paths_regex(excluded_paths)
        paths.reject { |path| path =~ ignored_regex }
      else
        paths
      end
    end

    # :reek:UtilityFunction
    def paths_regex(path_regexes)
      /#{path_regexes.join("|")}/
    end

    class AgWrapper

      def self.available?
        `which ag` =~ /ag/
      end

      def initialize(extensions)
        @extensions = extensions
      end

      def command(word)
        unescaped = ["ag", word, "-l", "-G", ruby_extensions_regex]

        Shellwords.shelljoin(unescaped)
      end

      private

      attr_reader :extensions

      def ruby_extensions_regex
        escaped = extensions.map do |extension|
          Regexp.escape(extension)
        end
        /(#{escaped.join("|")})$/
      end

    end

    class FindGrepWrapper

      def self.available?
        true
      end

      def initialize(extensions)
        @extensions = extensions
      end

      def command(word)
        escaped_word = Shellwords.shellescape(word)
        ignore_hidden_files = "-not -path '*/\.*'"

        "find . -type f #{extensions_expression} #{ignore_hidden_files} | xargs grep -l #{escaped_word}"
      end

      private

      attr_reader :extensions

      def extensions_expression
        names = extensions.map do |extension|
          escaped = Shellwords.shellescape(extension)
          "-name '*#{escaped}'"
        end
        names.join(" -o ")
      end

    end

  end

end
