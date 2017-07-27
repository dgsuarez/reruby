module Reruby

  class RenameConst

    def initialize(from: "", to: "", config: Config.default)
      @from = from
      @to = to
      @config = config
    end

    def perform
      candidates_for_usage = finder.paths_containing_word(from_namespace.last_const)
      candidates_for_require = finder.paths_containing_word(from_namespace.as_require)

      change_usages(candidates_for_usage)
      change_requires(candidates_for_require)
      rename_files(candidates_for_usage)
    end

    private

    attr_reader :from, :to, :config

    def change_requires(candidates_for_require)
      require_rewriter = RequireRewriter.new(from: from, to: to)

      candidates_for_require.each do |path|
        action = Actions::FileRewrite.new(path: path, rewriter: require_rewriter)
        action.perform
      end
    end

    def change_usages(candidates_for_usage)
      const_rewriter = UsageRewriter.new(from: from, to: to)

      candidates_for_usage.each do |path|
        action = Actions::FileRewrite.new(path: path, rewriter: const_rewriter)
        action.perform
      end
    end

    def rename_files(candidates_for_usage)
      rename_finder = FileRenames.new(from: from, to: to)
      renames = rename_finder.renames(candidates_for_usage)

      renamer = Actions::BulkFileOperations.new(renames: renames)
      renamer.perform
    end

    def from_namespace
      Namespace.from_source(from)
    end

    def finder
      FileFinder.new(config: config)
    end

  end

end
