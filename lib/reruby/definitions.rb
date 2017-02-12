module Reruby
  class Definitions


    def initialize(code)
      @code = code
      process
    end

    def scopes
      @extractor.found.keys
    end

    def found
      @extractor.found
    end

    private

    attr_reader :code

    def process
      @extractor = Extractor.new
      buffer = Parser::Source::Buffer.new('')
      parser = Parser::CurrentRuby.new
      buffer.source = code
      ast = parser.parse(buffer)
      @extractor.process(ast)
    end

    class Extractor < Parser::AST::Processor

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
          found[namespace_tracker.scope] = node

          content_nodes.each do |content_node|
            process(content_node)
          end
        end
      end


    end


  end
end
