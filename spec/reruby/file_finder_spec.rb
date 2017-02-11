require 'spec_helper'

describe Reruby::FileFinder do

  it "excludes files as given in the the config" do
    config_options = {
      "paths" => {
        "exclude" => ["^vendor"]
      }
    }

    stubbed_paths = [
      "app/vendor/hola",
      "vendor/hola",
      "lib/hola"
    ]

    config = Reruby::Config.new(fallback_config: Reruby::Config.default,
                                options: config_options)
    finder = Reruby::FileFinder.new(config: config)
    finder.stub(:paths_from_command).and_return(stubbed_paths)

    expected_paths = [
      "app/vendor/hola",
      "lib/hola"
    ]
    actual_paths = finder.paths_containing_word("")

    expect(actual_paths).to eq(expected_paths)
  end

end
