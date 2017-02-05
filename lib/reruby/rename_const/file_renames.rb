module Reruby
  class RenameConst::FileRenames

    attr_reader :from, :to, :paths

    def initialize(from: '', to: '')
      @from = from
      @to = to
    end

    def main_file_rename(paths)
      main_file = find_main_file(paths)
      return nil unless main_file

      rename = main_file.gsub(/\/#{from_last_path_part}.rb$/, "/#{to_as_path_part}.rb")

      [main_file, rename]
    end

    def test_file_rename(paths)
      detected_test_file = find_test_file(paths)
      return nil unless detected_test_file

      test_file_type = detected_test_file.split("/").first

      original_path_part_to_change = "#{from_last_path_part}_#{test_file_type}"
      new_path_part = "#{to_as_path_part}_#{test_file_type}"

      rename = detected_test_file.gsub(/\/#{original_path_part_to_change}.rb$/, "/#{new_path_part}.rb")

      [detected_test_file, rename]
    end

    def renames(paths)
      [main_file_rename(paths), test_file_rename(paths)].compact
    end

    private

    def find_main_file(paths)
      main_paths = paths.reject do |path|
        looks_like_test_path?(path)
      end

      expected_main_path_regex = /#{from.underscore}\.rb$/

      main_paths.detect do |path|
        path =~ expected_main_path_regex
      end
    end

    def find_test_file(paths)
      test_paths = paths.select do |path|
        looks_like_test_path?(path)
      end

      expected_test_path_regex = /#{from.underscore}_(#{test_file_types.join("|")})\.rb$/

      test_paths.detect do |path|
        path =~ expected_test_path_regex
      end
    end

    def from_last_path_part
      from.split("::").last.underscore
    end

    def to_as_path_part
      to.underscore
    end

    def test_file_types
      ["test", "spec"]
    end

    def looks_like_test_path?(path)
      test_file_types.any? do |test_file_type|
        path.start_with?("#{test_file_type}/")
      end
    end

  end
end
