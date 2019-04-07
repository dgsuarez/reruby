module Reruby
  class NamespacePaths

    def initialize(namespace: "", paths: [])
      @namespace = namespace
      @paths = paths
    end

    def root_folder
      relative_path = Namespace.from_source(namespace).relative_path
      main_file.gsub(relative_path, "")
    end

    def main_file
      main_file_regex = %r{/#{namespace_path_part}\.rb$}

      best_path_for_regex(main_file_regex, main_paths)
    end

    def main_folder
      main_folder_regex = %r{(.*?/#{namespace_path_part})/}

      candidate = best_path_for_regex(main_folder_regex, main_paths)

      candidate && main_folder_regex.match(candidate)[1]
    end

    def test_file
      test_file_regex = %r{/#{namespace_path_part}_(#{test_file_types.join("|")})\.rb$}

      best_path_for_regex(test_file_regex, test_paths)
    end

    def test_folder
      test_folder_regex = %r{(.*?/#{namespace_path_part})/.*_(#{test_file_types.join("|")})\.rb$}

      candidate = best_path_for_regex(test_folder_regex, test_paths)

      candidate && test_folder_regex.match(candidate)[1]
    end

    private

    attr_reader :namespace, :paths

    def test_file_types
      %w[test spec]
    end

    def best_path_for_regex(regex, paths)
      paths = paths.select do |path|
        path =~ regex
      end
      paths.min_by(&:length)
    end

    def test_paths
      paths.select do |path|
        looks_like_test_path?(path)
      end
    end

    def main_paths
      paths.reject do |path|
        looks_like_test_path?(path)
      end
    end

    def looks_like_test_path?(path)
      test_file_types.any? do |test_file_type|
        path.start_with?("#{test_file_type}/")
      end
    end

    def namespace_path_part
      namespace.underscore
    end

  end
end
