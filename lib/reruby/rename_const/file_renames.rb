module Reruby
  class RenameConst::FileRenames

    attr_reader :from, :to, :paths

    def initialize(from: '', to: '', paths: [])
      @from = from
      @to = to
      @paths = paths
    end

    def main_file_rename
      rename = main_file.gsub(/\/#{from_last_path_part}.rb$/, "/#{to_as_path_part}.rb")

      [main_file, rename]
    end

    def test_file_rename
      detected_test_file = test_file
      test_file_type = detected_test_file.split("/").first

      original_path_part_to_change = "#{from_last_path_part}_#{test_file_type}"
      new_path_part = "#{to_as_path_part}_#{test_file_type}"

      rename = detected_test_file.gsub(/\/#{original_path_part_to_change}.rb$/, "/#{new_path_part}.rb")

      [detected_test_file, rename]
    end

    def renames
      [main_file_rename, test_file_rename]
    end

    private

    def main_file
      expected_main_path_regex = /#{from.underscore}\.rb$/

      main_paths.detect do |path|
        path =~ expected_main_path_regex
      end
    end

    def test_file
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

    def main_paths
      paths.reject { |path| looks_like_test_path?(path)}
    end

    def test_paths
      paths.select { |path| looks_like_test_path?(path)}
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
