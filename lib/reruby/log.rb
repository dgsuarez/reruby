module Reruby
  class Log
    include Singleton

    attr_reader :logger

    def initialize
      @logger = Logger.new(STDERR)
      configure
    end

    def configure(config: Config.default)
      logger.level = log_level(config)
    end

    private

    def log_level(config)
      verbosity = config.get('verbose')
      if verbosity == 'very'
        Logger::DEBUG
      elsif verbosity
        Logger::INFO
      else
        Logger::WARN
      end
    end
  end
end
