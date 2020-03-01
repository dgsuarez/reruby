# frozen_string_literal: true

module Reruby
  class RenameConst < BaseRefactoring

    skip_step :autofix

    def prepare(from: '', to: '')
      @from = from
      @to = to
    end

    def refactor
      candidates_for_usage = finder.paths_containing_word(from_namespace.last_const)
      last_required_path_part = from_namespace.as_require.split('/').last
      candidates_for_require = finder.paths_containing_word(last_required_path_part)

      change_usages(candidates_for_usage)
      change_requires(candidates_for_require)
      rename_files(candidates_for_usage)
    end

    private

    attr_reader :from, :to

    def change_requires(candidates_for_require)
      candidates_for_require.each do |path|
        require_rewriter = RequireRewriter.new(path: path, from: from, to: to)
        action = Actions::FileRewrite.new(path: path, rewriter: require_rewriter)
        action.perform

        changed_files.add(changed: [path]) if action.changed?
      end
    end

    def change_usages(candidates_for_usage)
      const_rewriter = UsageRewriter.new(from: from, to: to)

      candidates_for_usage.each do |path|
        action = Actions::FileRewrite.new(path: path, rewriter: const_rewriter)
        action.perform

        changed_files.add(changed: [path]) if action.changed?
      end
    end

    def rename_files(candidates_for_usage)
      rename_finder = FileRenames.new(from: from, to: to)
      renames = rename_finder.renames(candidates_for_usage)

      renamer = Actions::BulkFileOperations.new(renames: renames)

      changed_files.merge!(renamer.perform)
    end

    def from_namespace
      Namespace.from_source(from)
    end

    def finder
      FileFinder.new(config: config)
    end

  end

end
