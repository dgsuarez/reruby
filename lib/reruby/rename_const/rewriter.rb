
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
      inline_consts = InlineConsts.from_node_tree(node)
      read_inline_consts(inline_consts)
    end

    private

    attr_reader :from_scope, :to, :opened_scope, :inline_consts

    def reset_inline_consts
      @inline_consts = []
    end

    def read_inline_consts(inline_consts, &b)
      if inline_consts.forced_root?
        shadowing_opened_namespace do
          read_inline_consts(inline_consts.without_forced_root, &b)
        end
        return
      end

      inline_consts.each_const do |current_node, const_path|
        rename(current_node) if match?(const_path)
      end

      opened_scope.push(inline_consts.as_source)
      b && b.call
      opened_scope.pop
    end

    def shadowing_opened_namespace
      old_opened_namespace = opened_scope.dup
      @opened_scope = []
      yield
      @opened_scope = old_opened_namespace
    end

    def open_namespace(node)
      const_node, *content_nodes = node.children
      inline_consts = InlineConsts.from_node_tree(const_node)

      read_inline_consts(inline_consts) do
        content_nodes.each do |content_node|
          process(content_node)
        end
      end
    end

    def rename(node)
      replace(node.loc.name, to)
    end

    def match?(inline_const_names)
      full_namespace = opened_scope + [inline_const_names.join("::")]
      current_scope = Scope.new(full_namespace)

      current_scope.can_resolve_to?(from_scope)
    end

  end


end
