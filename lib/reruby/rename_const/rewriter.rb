
module Reruby
  class RenameConst::Rewriter < Parser::Rewriter

    def initialize(from: "", to: "")
      @from_scope = Scope.new(from.split("::"))
      @opened_scope = []
      @to = to
      @inline_consts = []
    end

    def on_module(node)
      open_namespace(node)
    end

    def on_class(node)
      open_namespace(node)
    end

    def on_const(node)
      inline_const_nodes = reverse_const_tree(node)
      read_inline_consts(inline_const_nodes)
    end

    private

    attr_reader :from_scope, :to, :opened_scope, :inline_consts

    def reset_inline_consts
      @inline_consts = []
    end

    def read_inline_consts(const_nodes, &b)
      if const_nodes.empty?
        # Done processing inline consts, reset them and process
        # class/module contents if present
        opened_scope.push(inline_consts.join("::"))
        reset_inline_consts
        b && b.call
        opened_scope.pop
      elsif const_nodes.first.type == :cbase
        # The inline const starts with ::, so the external
        # opened namespace needs to be shadowed by an empty one
        # while we process
        shadowing_opened_namespace do
          read_next_inline_const(const_nodes.slice(1 .. -1), &b)
        end
      else
        # Add constant to the inline opened_scope and check for renaming need
        read_next_inline_const(const_nodes, &b)
      end
    end

    def shadowing_opened_namespace
      old_opened_namespace = opened_scope.dup
      @opened_scope = []
      yield
      @opened_scope = old_opened_namespace
    end

    def read_next_inline_const(const_nodes, &b)
      first_const, *rest_consts = const_nodes
      inline_consts.push(first_const.loc.name.source)
      rename(first_const) if match?
      read_inline_consts(rest_consts, &b)
      inline_consts.pop
    end

    def open_namespace(node)
      const_node, *content_nodes = node.children
      nodes_in_order = reverse_const_tree(const_node)

      read_inline_consts(nodes_in_order) do
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
      full_namespace = opened_scope + [inline_consts.join("::")]
      current_scope = Scope.new(full_namespace)

      current_scope.can_resolve_to?(from_scope)
    end

  end


end
