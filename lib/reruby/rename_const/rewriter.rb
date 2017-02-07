
module Reruby
  class RenameConst::Rewriter < Parser::Rewriter

    def initialize(from: "", to: "")
      @from_namespace = from.split("::")
      @to = to
      @external_namespace = []
    end

    def on_module(node)
      enter_external_namespace(node)
    end

    def on_class(node)
      enter_external_namespace(node)
    end

    def on_const(node)
      nodes_in_order = reverse_const_tree(node)
      process_const_nodes(nodes_in_order)
    end

    private

    attr_reader :from_namespace, :to, :external_namespace

    def process_const_nodes(const_nodes, &b)
      if const_nodes.empty?
        b && b.call
        return
      end
      first_const, *rest_consts = const_nodes
      external_namespace.push(first_const.loc.name.source)
      rename(first_const) if match?
      process_const_nodes(rest_consts, &b)
      external_namespace.pop
    end

    def enter_external_namespace(node)
      const_node, *content_nodes = node.children
      nodes_in_order = reverse_const_tree(const_node)

      process_const_nodes(nodes_in_order) do
        content_nodes.each do |content_node|
          process(content_node)
        end
      end
    end

    def reverse_const_tree(node)
      next_node, _ = node.children

      if next_node
        reverse_const_tree(next_node) + [node]
      else
        [node]
      end

    end

    def rename(node)
      replace(node.loc.name, to)
    end

    def match?
      current_scope = Scope.new([], external_namespace)

      current_scope.can_resolve_to?(from_scope)
    end

    def from_scope
      Scope.new(from_namespace.slice(0 .. -2), from_namespace.last(1))
    end

  end


end
