module Reruby
  class RequireNode

    def self.require?(node)
      method_name = node.loc.selector.source
      %w[require require_relative].include?(method_name)
    end

    def initialize(node)
      @node = node
    end

    def require_method
      node.loc.selector.source
    end

    def require_path
      required_expr = node.children.last.loc.expression
      required_expr.source.slice(1..-2)
    end

    def required_namespace
      Namespace.from_require_path(require_path)
    end

    def source
      node.loc.expression.source
    end

    private

    attr_reader :node

  end
end
