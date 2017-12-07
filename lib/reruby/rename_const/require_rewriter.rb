
module Reruby
  class RenameConst::RequireRewriter < Parser::Rewriter

    def initialize(from: "", to: "")
      @from_namespace = Namespace.from_source(from).relativize
      @to_namespace = Namespace.from_source(to).relativize
    end

    def on_send(node)
      method_name = node.loc.selector.source
      return unless require_method?(method_name)

      required_expr = node.children.last.loc.expression
      require_path = required_expr.source
      return unless requires_from?(require_path)

      new_require = change_require(require_path)

      replace(required_expr, new_require)
    end

    private

    attr_reader :from_namespace, :to_namespace

    def requires_from?(require_path_with_quotes)
      require_path = require_path_with_quotes.slice(1 .. -2)
      required_namespace = Namespace.from_require_path(require_path)

      required_namespace.nested_in_or_same_as?(from_namespace)
    end

    def require_method?(method_name)
      %w(require require_relative).include?(method_name)
    end

    def change_require(old_require)
      new_require_start = from_namespace.
        parent.adding(to_namespace).
        as_require

      old_require.sub(from_namespace.as_require, new_require_start)
    end

  end
end
