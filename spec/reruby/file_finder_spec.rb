require 'spec_helper'

describe Reruby::FileFinder do

  describe "#paths_containing_word" do
    it "lists the paths containing the word given" do

      config = Reruby::Config.new(fallback_config: Reruby::Config.default)
      finder = Reruby::FileFinder.new(config: config)

      expected_paths = ["spec/reruby/file_finder_example/another_find_finder_test_file.rb",
                        "spec/reruby/file_finder_example/file_finder_test_file.rb",
                        "spec/reruby/file_finder_example/vendor/vendor_file_finder_test.rb",
                        "spec/reruby/file_finder_spec.rb"]

      actual_paths = finder.paths_containing_word("FileFinderTest")
      expect(actual_paths.sort).to eq(expected_paths)
    end

    it "excludes files as given in the the config" do
      config_options = {
        "paths" => {
          "exclude" => ["vendor"]
        }
      }

      config = Reruby::Config.new(fallback_config: Reruby::Config.default,
                                  options: config_options)
      finder = Reruby::FileFinder.new(config: config)

      expected_paths = ["spec/reruby/file_finder_example/another_find_finder_test_file.rb",
                        "spec/reruby/file_finder_example/file_finder_test_file.rb",
                        "spec/reruby/file_finder_spec.rb"]

      actual_paths = finder.paths_containing_word("FileFinderTest")
      expect(actual_paths.sort).to eq(expected_paths)
    end
  end
end
