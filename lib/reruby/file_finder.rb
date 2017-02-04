require 'shellwords'

module Reruby
  class FileFinder

    def self.paths_containing_word(word)
      executable = find_executable('ag') || find_executable('ack')
      command = Shellwords.shelljoin([executable, "-G '\.(rb|rake|Rakefile)$'", "-l", word])
      `#{command}`.split("\n")
    end

    def self.find_executable(cmd)
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
