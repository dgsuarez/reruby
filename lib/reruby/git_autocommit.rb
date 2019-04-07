require 'git'

module Reruby
  class GitAutocommit
    ROOT_PATH = Dir.pwd

    def initialize
      @client = Git.open(ROOT_PATH)
    end

    def autocommit(msg)
      begin
        @client.add(all: true)
        @client.commit(msg)
      rescue StandardError => e
        raise(AutocommitError, e.message)
      end
      Reruby.logger.info 'Autocommit succesfully'
    end
  end

  class AutocommitError < StandardError
  end
end
