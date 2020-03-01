# frozen_string_literal: true

module Reruby
  class BaseRefactoring

    def self.skip_step(step)
      @steps_to_skip ||= {}
      @steps_to_skip[step] = true
    end

    def self.skip_step?(step)
      @steps_to_skip && @steps_to_skip[step]
    end

    def initialize(config: Config.default, **kwargs)
      @config = config
      @changed_files = ChangedFiles.new

      prepare(**kwargs)
    end

    def perform
      autocommit if autocommit?

      refactor

      autofix if autofix?
      print_report if print_report?
    end

    private

    attr_reader :config, :changed_files

    def prepare(*); end

    def refactor
      raise NotImplementedError
    end

    def perform_step?(step)
      !self.class.skip_step?(step)
    end

    def autocommit?
      perform_step?(:autocommit) && config.get('autocommit')
    end

    def autocommit
      message = config.get('autocommit-message')
      GitAutocommit.new.autocommit(message)
    end

    def autofix?
      perform_step?(:autofix) && config.get('rubocop_autofix')
    end

    def autofix
      RubocopAutofix.new(changed_files).clean
    end

    def print_report?
      perform_step?(:print_report)
    end

    def print_report
      print changed_files.report(format: config.get('report'))
    end

  end
end
