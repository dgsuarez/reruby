require 'git'

module Reruby
  class GitAutocommit
    AUTOCOMMIT_MSG = 'Reruby autocommit before refactoring'.freeze
    ROOT_PATH = File.expand_path('../../', File.dirname(__FILE__))

    def initialize
      @client = Git.open(ROOT_PATH)
    end

    def autocommit
      begin
        @client.add(all: true)
        @client.commit(AUTOCOMMIT_MSG)
      rescue StandardError => e
        raise(AutocommitError, e.message)
      end
      Reruby.logger.info "Autocommit succesfully"
    end
  end
end

class AutocommitError < StandardError
end
