
module Reruby
  class RenameConst::RequireRewriter < Parser::Rewriter

    def initialize(from:, to:, path:)
      @from_namespace = Namespace.from_source(from).relativize
      @to_namespace = Namespace.from_source(to).relativize
      @path = path
    end

    def on_send(node)
      return unless ParserWrappers::Require.require?(node)

      require_node = ParserWrappers::Require.build(node, path)
      return unless require_node.required_namespace.nested_in_or_same_as?(from_namespace)

      required_expr = node.children.last.loc.expression

      replace(required_expr, new_require_path(require_node))
    end

    private

    attr_reader :from_namespace, :to_namespace, :path

    def new_require_path(require_node)
      new_namespace = from_namespace.parent.adding(to_namespace)
      new_path = require_node.path_replacing_namespace(from_namespace, new_namespace)

      "'#{new_path}'"
    end

  end
end
