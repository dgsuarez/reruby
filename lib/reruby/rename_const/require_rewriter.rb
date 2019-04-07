module Reruby
  class RenameConst::RequireRewriter < Parser::TreeRewriter

    def initialize(from:, to:, path:)
      @from_namespace = Namespace.from_source(from).relativize
      @to_namespace = Namespace.from_source(to).relativize
      @path = path
    end

    def on_send(node)
      return unless ParserWrappers::Require.require?(node)

      require_node = ParserWrappers::Require.build(node, path)
      return unless require_node.requires_same_or_nested_namespace?(from_namespace)

      replace(node.loc.expression, new_require_source(require_node))
    end

    private

    attr_reader :from_namespace, :to_namespace, :path

    def new_require_source(require_node)
      new_namespace = from_namespace.parent.adding(to_namespace)

      require_node.source_replacing_namespace(from_namespace, new_namespace)
    end

  end
end
