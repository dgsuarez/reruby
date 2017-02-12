module Reruby

  class RenameConst

    def initialize(from: "", to: "", config: Config.default)
      @from = from
      @to = to
      @config = config
    end

    def perform
      candidate_paths = find_candidate_paths

      rewriter = Rewriter.new(from: from, to: to)
      rename_finder = FileRenames.new(from: from, to: to)

      candidate_paths.each do |path|
        action = Actions::FileRewrite.new(path: path, rewriter: rewriter)
        action.perform
      end

      renames = rename_finder.renames(candidate_paths)

      Actions::BulkFileRenamer.bulk_rename(renames)
    end

    private

    attr_reader :from, :to, :config

    def original_class_name
      from.split("::").last
    end

    def find_candidate_paths
      finder = FileFinder.new(config: config)
      finder.paths_containing_word(original_class_name)
    end

  end

end
