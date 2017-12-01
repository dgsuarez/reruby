require 'spec_helper'

describe Reruby::FileFinder do

  describe "#paths_containing_word" do
    it "lists the paths containing the given word when using ag" do
      finder = Reruby::FileFinder.new

      expected_paths = ["spec/reruby/file_finder_example/Rakefile",
                        "spec/reruby/file_finder_example/another_find_finder_test_file.rb",
                        "spec/reruby/file_finder_example/file_finder_test_file.rb",
                        "spec/reruby/file_finder_example/vendor/vendor_file_finder_test.rb",
                        "spec/reruby/file_finder_spec.rb"]

      actual_paths = finder.paths_containing_word("FileFinderTest")
      expect(actual_paths.sort).to eq(expected_paths)
    end

    it "lists the paths containing the given word when using find+grep" do
      allow(Reruby::FileFinder::AgWrapper).to receive(:available?).and_return(false)

      finder = Reruby::FileFinder.new

      expected_paths = ["spec/reruby/file_finder_example/Rakefile",
                        "spec/reruby/file_finder_example/another_find_finder_test_file.rb",
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

      expected_paths = ["spec/reruby/file_finder_example/Rakefile",
                        "spec/reruby/file_finder_example/another_find_finder_test_file.rb",
                        "spec/reruby/file_finder_example/file_finder_test_file.rb",
                        "spec/reruby/file_finder_spec.rb"]

      actual_paths = finder.paths_containing_word("FileFinderTest")
      expect(actual_paths.sort).to eq(expected_paths)
    end
  end
end
