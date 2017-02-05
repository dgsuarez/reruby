module Reruby

  class RenameConst

    def initialize(from: "", to: "")
      @from = from
      @to = to
    end

    def perform
      candidate_paths = find_candidate_paths

      rewriter = Rewriter.new(from: from, to: to)
      rename_finder = FileRenames.new(from: from, to: to)

      candidate_paths.each do |path|
        action = FileRewriteAction.new(path: path, rewriter: rewriter)
        action.perform
      end

      renames = rename_finder.renames(candidate_paths)

      BulkFileRenamer.bulk_rename(renames)
    end

    private

    attr_reader :from, :to

    def original_class_name
      from.split("::").last
    end

    def find_candidate_paths
      FileFinder.paths_containing_word(original_class_name)
    end

  end

end
