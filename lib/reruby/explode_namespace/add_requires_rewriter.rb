# frozen_string_literal: true

module Reruby
  class ExplodeNamespace::AddRequiresRewriter < Parser::TreeRewriter

    def initialize(path:, namespace_to_explode:, namespaces_to_add:)
      @path = path
      @namespace_to_explode = Namespace.from_source(namespace_to_explode)
      @namespaces_to_add = namespaces_to_add.map do |namespace|
        Namespace.from_source(namespace)
      end
    end

    def on_send(node)
      return unless ParserWrappers::Require.require?(node)

      require_node = ParserWrappers::Require.build(node, path)

      return unless require_node.requires_namespace?(namespace_to_explode)

      new_requires = add_requires(require_node)

      replace(node.loc.expression, new_requires)
    end

    private

    attr_reader :namespace_to_explode, :namespaces_to_add, :path

    def add_requires(require_node)
      new_requires_source = namespaces_to_add.map do |namespace|
        require_node.source_replacing_namespace(namespace_to_explode, namespace)
      end

      ([require_node.source] + new_requires_source).join("\n")
    end

  end
end
