module Reruby
  class RenameConst::FileRenames

    attr_reader :from, :to, :paths

    def initialize(from: '', to: '')
      @from = from
      @to = to
    end

    def main_file_rename(paths)
      main_file = namespace_paths(paths).main_file
      return nil unless main_file

      rename = main_file.sub(/\/#{from_last_path_part}.rb$/, "/#{to_as_path_part}.rb")

      [main_file, rename]
    end

    def main_folder_rename(paths)
      main_folder = namespace_paths(paths).main_folder

      folder_rename(main_folder)
    end

    def test_file_rename(paths)
      detected_test_file = namespace_paths(paths).test_file
      return nil unless detected_test_file

      test_file_type = detected_test_file.split("/").first

      original_path_part_to_change = "#{from_last_path_part}_#{test_file_type}"
      new_path_part = "#{to_as_path_part}_#{test_file_type}"

      rename = detected_test_file.sub(/\/#{original_path_part_to_change}.rb$/, "/#{new_path_part}.rb")

      [detected_test_file, rename]
    end

    def test_folder_rename(paths)
      test_folder = namespace_paths(paths).test_folder

      folder_rename(test_folder)
    end

    def renames(paths)
      [main_file_rename(paths),
       main_folder_rename(paths),
       test_file_rename(paths),
       test_folder_rename(paths)].compact
    end

    private

    def namespace_paths(paths)
      NamespacePaths.new(namespace: from, paths: paths)
    end

    def from_last_path_part
      from.split("::").last.underscore
    end

    def to_as_path_part
      to.underscore
    end

    def folder_rename(folder)
      return nil unless folder

      rename = folder.sub(/\/#{from_last_path_part}$/, "/#{to_as_path_part}")

      [folder, rename]
    end

  end
end
