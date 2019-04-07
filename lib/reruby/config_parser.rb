module Reruby
  class ConfigParser
    def initialize(cli_options: {})
      @cli_options = cli_options
    end

    def config
      file_config = Config.new(
        options: parse_file_options,
        fallback_config: Config.default
      )

      Config.new(
        options: parse_cli_options,
        fallback_config: file_config
      )
    end

    private

    attr_reader :cli_options

    def parse_cli_options
      cli_options.keys.reduce({}) do |config_opts, cli_option|
        new_config = cli_mappings[cli_option] || {}
        config_opts.merge(new_config)
      end
    end

    def parse_file_options
      config_file_path = possible_config_file_paths.detect do |path|
        path && File.exist?(path)
      end
      return {} unless config_file_path

      YAML.safe_load(File.read(config_file_path))
    end

    def possible_config_file_paths
      [
        cli_options['config-file'],
        '.reruby.yml',
        File.join(Dir.home, '.reruby.yml')
      ]
    end

    # Inline configuration hash
    def cli_mappings # rubocop:disable Metrics/AbcSize
      {
        'ignore-paths' => {
          'paths' => {
            'exclude' => cli_options['ignore-paths']
          }
        },
        'ruby-extensions' => {
          'ruby_extensions' => cli_options['ruby-extensions']
        },
        'verbose' => {
          'verbose' => cli_options['verbose']
        },
        'report' => {
          'report' => cli_options['report']
        },
        'rubocop-autofix' => {
          'rubocop_autofix' => cli_options['rubocop-autofix']
        },
        'keyword-arguments' => {
          'extract_method' => {
            'keyword_arguments' => cli_options['keyword-arguments']
          }
        },
        'autocommit' => {
          'autocommit' => cli_options['autocommit']
        },
        'autocommit-message' => {
          'autocommit-message' => cli_options['autocommit-message']
        }
      }
    end
  end
end
