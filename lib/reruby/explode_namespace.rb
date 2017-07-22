module Reruby
  class ExplodeNamespace

    def initialize(namespace_to_explode: "" , config: Config.default)
      @namespace_to_explode = namespace_to_explode
      @config = config
      @ns_paths = NamespacePaths.new(namespace: namespace_to_explode, paths: find_candidate_paths)
    end

    def perform
      create_new_files
      remove_nested_namespaces
    end

    private

    attr_reader :namespace_to_explode, :config, :ns_paths

    def create_new_files
      code = File.read(ns_paths.main_path)
      source_extractor = ChildrenNamespaceFiles.new(namespace_to_explode: namespace_to_explode,
                                                    code: code,
                                                    root_path: ns_paths.root_folder)

      file_creations = source_extractor.files_to_create
      file_operations = Actions::BulkFileOperations.new(creates: file_creations)
      file_operations.perform
    end

    def remove_nested_namespaces
      rewriter = MainFileRewriter.new(namespace_to_explode: namespace_to_explode)
      action = Actions::FileRewrite.new(path: ns_paths.main_path, rewriter: rewriter)
      action.perform
    end

    def original_class_name
      namespace_to_explode.split("::").last
    end

    def find_candidate_paths
      finder = FileFinder.new(config: config)
      finder.paths_containing_word(original_class_name)
    end
  end
end
