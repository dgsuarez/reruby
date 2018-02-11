module Reruby
  class InstancesToReaders

    def initialize(namespace: "", config: Config.default)
      @namespace = namespace
      @config = config
      @ns_paths = NamespacePaths.new(namespace: namespace, paths: find_paths_using_class)
      @changed_files = ChangedFiles.new
    end

    def perform
      rewriter = Rewriter.new(namespace: namespace)
      path = ns_paths.main_file

      action = Actions::FileRewrite.new(path: path, rewriter: rewriter)
      action.perform

      changed_files.add(changed: [path]) if action.changed?

      print changed_files.report(format: config.get('format'))
    end

    private

    attr_reader :namespace, :config, :ns_paths, :changed_files

    def original_class_name
      namespace.split("::").last
    end

    def find_paths_using_class
      finder = FileFinder.new(config: config)
      finder.paths_containing_word(original_class_name)
    end

  end
end
