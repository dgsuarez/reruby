# frozen_string_literal: true

module Reruby
  class InstancesToReaders < BaseRefactoring

    def prepare(namespace: '')
      @namespace = namespace
      @ns_paths = NamespacePaths.new(namespace: namespace, paths: find_paths_using_class)
    end

    def refactor
      rewriter = Rewriter.new(namespace: namespace)
      path = ns_paths.main_file

      action = Actions::FileRewrite.new(path: path, rewriter: rewriter)
      action.perform

      changed_files.add(changed: [path]) if action.changed?
    end

    private

    attr_reader :namespace, :ns_paths

    def original_class_name
      namespace.split('::').last
    end

    def find_paths_using_class
      finder = FileFinder.new(config: config)
      finder.paths_containing_word(original_class_name)
    end

  end
end
