module Reruby
  class ExplodeNamespace

    def initialize(namespace_to_explode: "", config: Config.default)
      @namespace_to_explode = namespace_to_explode
      @config = config
      @ns_paths = NamespacePaths.new(namespace: namespace_to_explode, paths: find_paths_using_class)
      @changed_files = ChangedFiles.new
    end

    def perform
      create_new_files
      remove_nested_namespaces
      add_new_requires
      print_report
    end

    private

    attr_reader :namespace_to_explode, :config, :ns_paths

    def create_new_files
      file_creations = children_files.files_to_create
      file_operations = Actions::BulkFileOperations.new(creates: file_creations)
      changed_files.merge!(file_operations.perform)
    end

    def remove_nested_namespaces
      path = ns_paths.main_file
      rewriter = MainFileRewriter.new(namespace_to_explode: namespace_to_explode)
      action = Actions::FileRewrite.new(path: path, rewriter: rewriter)
      action.perform

      changed_files.add(changed: [path]) if action.changed?
    end

    def add_new_requires
      namespaces_to_add = children_files.namespaces.map(&:as_source)
      rewriter = AddRequiresRewriter.new(namespace_to_explode: namespace_to_explode,
                                         namespaces_to_add: namespaces_to_add)

      find_paths_with_require.each do |path|
        action = Actions::FileRewrite.new(path: path, rewriter: rewriter)
        action.perform
        changed_files.add(changed: [path]) if action.changed?
      end
    end

    def print_report
      print changed_files.report(format: config.get('report'))
    end

    def original_class_name
      namespace_to_explode.split("::").last
    end

    def find_paths_using_class
      finder = FileFinder.new(config: config)
      finder.paths_containing_word(original_class_name)
    end

    def find_paths_with_require
      require_path = Namespace::Relative.new(namespace_to_explode).as_require
      finder = FileFinder.new(config: config)
      finder.paths_containing_word(require_path)
    end

    def children_files
      code = File.read(ns_paths.main_file)
      ChildrenNamespaceFiles.new(namespace_to_explode: namespace_to_explode,
                                 code: code,
                                 root_path: ns_paths.root_folder)
    end
  end
end
