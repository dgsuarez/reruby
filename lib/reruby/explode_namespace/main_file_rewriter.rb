
module Reruby
  class ExplodeNamespace::MainFileRewriter < Parser::Rewriter

    def initialize(namespace_to_explode: "")
      @namespace_to_explode = Namespace.from_source(namespace_to_explode)
      @namespace_tracker = Namespace::Tracker.new
    end

    def on_module(node)
      open_namespace(node)
    end

    def on_class(node)
      open_namespace(node)
    end

    private

    attr_reader :namespace_to_explode, :namespace_tracker

    def open_namespace(node)
      const_node, *content_nodes = node.children
      const_group = ParserConstGroup.from_node_tree(const_node)

      namespace_tracker.open_namespace(const_group.as_namespace) do
        current_namespace = namespace_tracker.namespace

        if current_namespace.nested_one_level_in?(namespace_to_explode)
          remove(node.loc.expression)
        else
          content_nodes.each { |content_node| process(content_node) }
        end
      end
    end

  end
end
