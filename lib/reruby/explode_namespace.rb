# frozen_string_literal: true

module Reruby
  class ExplodeNamespace < BaseRefactoring

    def prepare(namespace_to_explode: '')
      @namespace_to_explode = namespace_to_explode
      @ns_paths = NamespacePaths.new(namespace: namespace_to_explode, paths: find_paths_using_class)
    end

    def refactor
      create_new_files
      remove_nested_namespaces
      add_new_requires
    end

    private

    attr_reader :namespace_to_explode, :ns_paths

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

      find_paths_with_require.each do |path|
        rewriter = AddRequiresRewriter.new(
          path: path, namespace_to_explode: namespace_to_explode, namespaces_to_add: namespaces_to_add
        )
        action = Actions::FileRewrite.new(path: path, rewriter: rewriter)
        action.perform
        changed_files.add(changed: [path]) if action.changed?
      end
    end

    def original_class_name
      namespace_to_explode.split('::').last
    end

    def find_paths_using_class
      finder = FileFinder.new(config: config)
      finder.paths_containing_word(original_class_name)
    end

    def find_paths_with_require
      require_path = Namespace.from_source(namespace_to_explode).as_require
      last_required_path_part = require_path.split('/').last
      finder = FileFinder.new(config: config)
      finder.paths_containing_word(last_required_path_part)
    end

    def children_files
      code = File.read(ns_paths.main_file)
      ChildrenNamespaceFiles.new(namespace_to_explode: namespace_to_explode,
                                 code: code,
                                 root_path: ns_paths.root_folder)
    end
  end
end
