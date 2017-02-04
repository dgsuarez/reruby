
module Reruby
  class RenameClass

    def initialize(from: "", to: "")
      @from = from
      @to = to
    end

    def perform(code)
      buffer = Parser::Source::Buffer.new('(example)')
      buffer.source = code
      parser = Parser::CurrentRuby.new
      ast = parser.parse(buffer)
      rewriter = Rewriter.new(from, to)
      rewriter.rewrite(buffer, ast)
    end

    private

    attr_reader :from, :to

    class Rewriter < Parser::Rewriter

      attr_reader :from_namespace, :to, :external_namespace

      def initialize(from, to)
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

      def enter_external_namespace(node)
        external_namespace.push node.loc.name.source
        process(node.children.last)
        external_namespace.pop
      end

      def on_const(node)
        rename(node) if match?(node)
      end

      def get_inline_namespace(node)
        next_node, current_const = node.children
        const_name = current_const.to_s

        if next_node
          get_inline_namespace(next_node) + [const_name]
        else
          [const_name]
        end
      end

      def rename(node)
        inline_until_class = get_inline_namespace(node).slice(0 .. -2)
        replacement = (inline_until_class + [to]).join("::")

        replace(node.loc.expression, replacement)
      end

      def match?(node)
        inline_namespace = get_inline_namespace(node)
        current_scope = Scope.new(external_namespace, inline_namespace)

        current_scope.can_resolve_to?(from_scope)
      end

      def from_scope
        Scope.new(from_namespace.slice(0 .. -2), from_namespace.last(1))
      end

    end


  end
end
