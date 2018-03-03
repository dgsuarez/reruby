module Reruby
  class ExplodeNamespace::AddRequiresRewriter < Parser::Rewriter

    def initialize(namespace_to_explode:, namespaces_to_add:)
      @namespace_to_explode = Namespace.from_source(namespace_to_explode)
      @namespaces_to_add = namespaces_to_add.map do |namespace|
        Namespace.from_source(namespace)
      end
    end

    def on_send(node)
      return unless ParserWrappers::Require.require?(node)
      require_node = ParserWrappers::Require.build(node, nil)

      return unless namespace_to_explode == require_node.required_namespace

      new_requires = add_requires(require_node)

      replace(node.loc.expression, new_requires)
    end

    private

    attr_reader :namespace_to_explode, :namespaces_to_add

    def add_requires(require_node)
      new_requires_source = namespaces_to_add.map do |namespace|
        require_for_namespace(require_node, namespace)
      end

      ([require_node.source] + new_requires_source).join("\n")
    end

    # :reek:FeatureEnvy
    def require_for_namespace(require_node, namespace)
      require_path = require_node.path_replacing_namespace(namespace_to_explode, namespace)
      "#{require_node.require_method} '#{require_path}'"
    end

  end
end
