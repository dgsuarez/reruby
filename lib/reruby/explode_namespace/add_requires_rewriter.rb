module Reruby
  class ExplodeNamespace::AddRequiresRewriter < Parser::Rewriter

    def initialize(namespace_to_explode:, namespaces_to_add:)
      @namespace_to_explode = Namespace.from_source(namespace_to_explode)
      @namespaces_to_add = namespaces_to_add.map do |namespace|
        Namespace.from_source(namespace)
      end
    end

    def on_send(node)
      method_name = node.loc.selector.source
      return unless require_method?(method_name)

      required_expr = node.children.last.loc.expression
      require_path = required_expr.source
      return unless requires_from?(require_path)

      new_requires = add_requires(method_name, node)

      replace(node.loc.expression, new_requires)
    end

    private

    attr_reader :namespace_to_explode, :namespaces_to_add

    def add_requires(method_name, require_node)
      new_requires_code = namespaces_to_add.map do |namespace|
        "#{method_name} '#{namespace.as_require}'"
      end

      current_require_code = require_node.loc.expression.source
      ([current_require_code] + new_requires_code).join("\n")
    end

    def requires_from?(require_path_with_quotes)
      require_path = require_path_with_quotes.slice(1..-2)
      required_namespace = Namespace.from_require_path(require_path)

      required_namespace.nested_in_or_same_as?(namespace_to_explode)
    end

    def require_method?(method_name)
      %w(require require_relative).include?(method_name)
    end
  end
end
