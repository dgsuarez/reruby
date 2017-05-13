
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
      inline_consts = ParserConstGroup.from_node_tree(const_node)

      namespace_tracker.open_namespace(inline_consts.as_namespace) do
        if nested_one_level?(namespace_tracker.namespace)
          remove(node.loc.expression)
        else
          content_nodes.each { |n| process(n) }
        end
      end
    end

    def nested_one_level?(const)
      nesting = const.nesting_level_in(namespace_to_explode)
      nesting == 1
    end

  end
end
