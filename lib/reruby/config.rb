# frozen_string_literal: true

module Reruby
  class Config

    def self.default
      options = {
        'paths' => {
          'exclude' => ['^vendor/']
        },
        'verbose' => 'a bit',
        'ruby_extensions' => ['.rake', '.rb', 'Rakefile'],
        'autocommit-message' => 'Reruby autocommit before refactoring'
      }

      new(options: options)
    end

    def initialize(options: {}, fallback_config: nil)
      @options = options
      @fallback_config = fallback_config
    end

    def get(key_path)
      value = get_without_fallback(key_path)

      if !value && fallback_config
        fallback_config.get(key_path)
      else
        value
      end
    end

    private

    attr_reader :options, :fallback_config

    def get_without_fallback(key_path)
      keys = key_path.split('.')
      keys.reduce(options) do |conf, key|
        conf && conf[key]
      end
    end

  end
end
