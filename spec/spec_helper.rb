$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'reruby'

require 'byebug'
require 'active_support/core_ext/string/strip'

# :reek:UtilityFunction
def namespace(consts)
  Reruby::Namespace.from_list(consts)
end

# :reek:UtilityFunction
def inline_refactor(code, refactoring_action)
  rewriter = Reruby::Actions::StringRewrite.new(code, refactoring_action)
  rewriter.perform
end

# :reek:UtilityMethod
def build_code_region(code, range_expression)
  Reruby::ParserWrappers::CodeRegion.new(code, Reruby::TextRange.parse(range_expression))
end

# :reek:UtilityFunction
def config_with_json_report
  Reruby::Config.new(
    options: { 'report' => 'json' },
    fallback_config: Reruby::Config.default
  )
end

class NoopBulkFileOperations
  def initialize(renames: [], creates: {}, deletes: [])
    @renames = renames
    @creates = creates
    @deletes = deletes
  end

  def perform
    Reruby::ChangedFiles.new(renamed: renames, created: creates.keys)
  end

  private

  attr_reader :renames, :creates, :deletes
end
