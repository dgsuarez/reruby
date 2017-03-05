module Reruby
  class NamespacePaths

    def initialize(namespace: "", possible_paths: [])
      @namespace = namespace
      @possible_paths = possible_paths
    end

    def main_path
      main_paths = possible_paths.reject do |path|
        looks_like_test_path?(path)
      end

      expected_main_path_regex = /\/#{namespace.underscore}\.rb$/

      best_path_for_regex(expected_main_path_regex, main_paths)
    end

    def test_path
      test_paths = possible_paths.select do |path|
        looks_like_test_path?(path)
      end

      expected_test_path_regex = /\/#{namespace.underscore}_(#{test_file_types.join("|")})\.rb$/

      best_path_for_regex(expected_test_path_regex, test_paths)
    end

    private

    attr_reader :namespace, :possible_paths

    def test_file_types
      ["test", "spec"]
    end

    def best_path_for_regex(regex, paths)
      possible_paths = paths.select do |path|
        path =~ regex
      end
      possible_paths.sort_by(&:length).first
    end


    def looks_like_test_path?(path)
      test_file_types.any? do |test_file_type|
        path.start_with?("#{test_file_type}/")
      end
    end

  end
end
