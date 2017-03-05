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
      namespace_paths(paths).main_path
    end

    def find_test_file(paths)
      namespace_paths(paths).test_path
    end

    def namespace_paths(paths)
      NamespacePaths.new(namespace: from, paths: paths)
    end

    def from_last_path_part
      from.split("::").last.underscore
    end

    def to_as_path_part
      to.underscore
    end

  end
end
