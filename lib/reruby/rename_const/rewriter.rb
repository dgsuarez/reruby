
module Reruby
  class RenameConst::Rewriter < Parser::Rewriter

    def initialize(from: "", to: "")
      @from_namespace = Namespace.from_source(from).relativize
      @namespace_tracker = Namespace::Tracker.new
      @to = to
    end

    def on_module(node)
      open_namespace(node)
    end

    def on_class(node)
      open_namespace(node)
    end

    def on_const(node)
      inline_consts = ParserConstGroup.from_node_tree(node)
      process_inline_consts(inline_consts)
    end

    private

    attr_reader :from_namespace, :to, :namespace_tracker

    def process_inline_consts(inline_consts)
      inline_consts.each_sub do |sub_inline_consts|
        current_node = sub_inline_consts.last_node
        rename(current_node) if match?(sub_inline_consts)
      end
    end

    def open_namespace(node)
      const_node, *content_nodes = node.children
      inline_consts = ParserConstGroup.from_node_tree(const_node)

      process_inline_consts(inline_consts)

      namespace_tracker.open_namespace(inline_consts.as_namespace) do
        content_nodes.each do |content_node|
          process(content_node)
        end
      end
    end

    def rename(node)
      replace(node.loc.name, to)
    end

    def match?(inline_consts)
      current_namespace = namespace_tracker.namespace.adding(inline_consts.as_namespace)
      current_namespace.can_resolve_to?(from_namespace)
    end

  end


end
