
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

      attr_reader :from, :to, :namespace_path, :const_path

      def initialize(from, to)
        @from = from
        @to = to
        @namespace_path = []
        @const_path = []
      end

      def on_module(node)
        namespace_path.push node.loc.name.source
        node.children.each do |n|
          process(n)
        end
        namespace_path.pop
      end

      def on_const(node)
        next_const, current_const = node.children
        const_path.push current_const

        if next_const
          process(next_const)
        elsif match?
          rename_const(node)
        end
        const_path.pop
      end

      def rename_const(node)
        replacement = if namespace_path.empty?
                        to
                      else
                        namespace_replacement = namespace_path.join("::") + "::"
                        to.sub(namespace_replacement, "")
                      end
        replace(node.loc.expression, replacement)
      end

      def match?
        full_path = (namespace_path + const_path.reverse).join("::")
        full_path == from
      end

    end


  end
end
