module Reruby
  class DefinedConsts


    def initialize(code)
      @code = code
      @finder = DefinedConstsFinder.new
      find_defined_consts
    end

    def namespaces
      finder.found.keys
    end

    def found
      finder.found
    end

    private

    attr_reader :code, :finder

    def find_defined_consts
      buffer = Parser::Source::Buffer.new('')
      parser = Parser::CurrentRuby.new
      buffer.source = code
      ast = parser.parse(buffer)
      finder.process(ast)
    end

    class DefinedConstsFinder < Parser::AST::Processor

      attr_reader :found, :namespace_tracker

      def initialize
        @found = {}
        @namespace_tracker = NamespaceTracker.new
      end

      def on_module(node)
        open_namespace(node)
      end

      def on_class(node)
        open_namespace(node)
      end

      def open_namespace(node)
        const_node, *content_nodes = node.children
        inline_consts = InlineConsts.from_node_tree(const_node)

        namespace_tracker.open_namespace(inline_consts) do
          found[namespace_tracker.namespace] = node

          content_nodes.each do |content_node|
            process(content_node)
          end
        end
      end


    end


  end
end
