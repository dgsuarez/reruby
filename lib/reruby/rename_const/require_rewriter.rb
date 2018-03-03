
module Reruby
  class RenameConst::RequireRewriter < Parser::Rewriter

    def initialize(from:, to:, path:)
      @from_namespace = Namespace.from_source(from).relativize
      @to_namespace = Namespace.from_source(to).relativize
      @path = path
    end

    def on_send(node)
      return unless ParserWrappers::Require.require?(node)

      require_node = ParserWrappers::Require.new(node)
      return unless require_node.required_namespace.nested_in_or_same_as?(from_namespace)

      required_expr = node.children.last.loc.expression

      replace(required_expr, new_require_path(require_node))
    end

    private

    attr_reader :from_namespace, :to_namespace, :path

    def new_require_path(require_node)
      new_require_start = from_namespace
                          .parent
                          .adding(to_namespace)
                          .as_require

      old_path = require_node.require_path
      new_path = old_path.sub(from_namespace.as_require, new_require_start)
      "'#{new_path}'"
    end

  end
end
