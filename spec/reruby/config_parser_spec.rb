require 'spec_helper'

describe Reruby::ConfigParser do

  it 'parses options sent by the cli' do
    cli_options = {
      'ignore-paths' => ['^vendor/', '^log/'],
      'ruby-extensions' => %w[rabl rb],
      'verbose' => 'very'
    }

    parser = Reruby::ConfigParser.new(cli_options: cli_options)

    expect(parser.config.get('paths.exclude')).to eq cli_options['ignore-paths']
    expect(parser.config.get('ruby_extensions')).to eq cli_options['ruby-extensions']
    expect(parser.config.get('verbose')).to eq 'very'
  end

  it 'reads the local config file' do
    config_contents = File.read('spec/assets/sample_config.yml')

    allow(File).to receive(:exist?) { false }
    allow(File).to receive(:exist?).with('.reruby.yml') { true }
    allow(File).to receive(:read).with('.reruby.yml') { config_contents }

    parser = Reruby::ConfigParser.new(cli_options: {})

    expect(parser.config.get('paths.exclude')).to eq ['^log/']
    expect(parser.config.get('ruby_extensions')).to eq ['.rb']
  end

  it 'reads the file given in the config' do
    cli_options = {
      'config-file' => 'spec/assets/sample_config.yml'
    }

    parser = Reruby::ConfigParser.new(cli_options: cli_options)

    expect(parser.config.get('paths.exclude')).to eq ['^log/']
    expect(parser.config.get('ruby_extensions')).to eq ['.rb']
  end

end
