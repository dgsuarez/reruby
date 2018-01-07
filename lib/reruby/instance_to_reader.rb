module Reruby
  class InstanceToReader

    def initialize(namespace: "", config: Config.default)
      @namespace = namespace
      @config = config
      @ns_paths = NamespacePaths.new(namespace: namespace, paths: find_paths_using_class)
    end

    def perform
      rewriter = Rewriter.new(namespace: namespace)
      action = Actions::FileRewrite.new(path: ns_paths.main_file, rewriter: rewriter)
      action.perform
    end

    private

    attr_reader :namespace, :config, :ns_paths

    def original_class_name
      namespace.split("::").last
    end

    def find_paths_using_class
      finder = FileFinder.new(config: config)
      finder.paths_containing_word(original_class_name)
    end

  end
end
