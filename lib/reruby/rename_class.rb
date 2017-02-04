module Reruby

  class RenameClass

    def initialize(from: "", to: "")
      @from = from
      @to = to
    end

    def perform
      rewriter = RenameClassRewriter.new(from: from, to: to)
      candidate_paths.each do |path|
        action = FileRewriteAction.new(path: path, rewriter: rewriter)
        action.perform
      end
    end

    private

    attr_reader :from, :to

    def original_class_name
      from.split("::").last
    end

    def candidate_paths
      FileFinder.paths_containing_word(original_class_name)
    end

  end

end
