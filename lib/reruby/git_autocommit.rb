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
      rescue StandardError
        raise(AutocommitError, $ERROR_INFO.message)
      end
      Reruby.logger.info 'Autocommit succesfully'
    end
  end

  class AutocommitError < StandardError
  end
end
