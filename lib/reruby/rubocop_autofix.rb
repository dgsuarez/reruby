module Reruby
  class RubocopAutofix

    def initialize(changed_files)
      @changed_files = changed_files
    end

    def clean
      _, stdout, = Open3.popen3(command)
      stdout.readlines
    end

    private

    attr_reader :changed_files

    def command
      files = Shellwords.shelljoin(changed_files.written)
      "which rubocop && rubocop --auto-correct #{files}"
    end

  end
end
