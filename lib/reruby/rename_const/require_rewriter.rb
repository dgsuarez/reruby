
module Reruby
  class RenameConst::RequireRewriter < Parser::Rewriter

    def initialize(from: "", to: "")
      @from_namespace = Namespace.from_source(from).relativize
      @to = to
    end

    def on_send(node)
      method_name = node.loc.selector.source
      return unless require_method?(method_name)

      required_expr = node.children.last.loc.expression
      return unless requires_from?(required_expr.source)

      replace(required_expr, new_require)
    end

    private

    attr_reader :from_namespace, :to

    def requires_from?(required_str)
      require_expr = required_str.slice(1 .. -2)
      require_expr == from_namespace.as_require
    end

    def require_method?(method_name)
      %w(require require_relative).include?(method_name)
    end

    def new_require
      "'#{to.underscore}'"
    end

  end
end
