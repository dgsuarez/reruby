module Reruby
  module ParserWrappers
    class CodeRegion

      def initialize(code, text_range)
        @code = code
        @text_range = text_range
      end

      def source
        sources = inner_nodes.map do |node|
          node.loc.expression.source
        end

        sources.join("\n")
      end

      def undefined_variables
        known_variables = Set.new
        seen_variables = Set.new

        inner_nodes.each do |node|
          extractor = UndefinedVariablesExtractor.new(known_variables, seen_variables)
          extractor.process(node)
        end

        (seen_variables - known_variables).to_a
      end

      def includes?(node)
        text_range.includes_node?(node)
      end

      private

      attr_reader :code, :text_range

      def inner_nodes
        extractor = RegionExtractor.new(self)
        extractor.process(parsed_outer_code)
        extractor.nodes
      end

      def parsed_outer_code
        buffer = Parser::Source::Buffer.new('')
        parser = Parser::CurrentRuby.new
        buffer.source = code
        parser.parse(buffer)
      end

      class RegionExtractor

        attr_reader :region, :nodes

        def initialize(region)
          @region = region
          @nodes = []
        end

        def process(node)
          return unless node.is_a?(Parser::AST::Node)
          if region.includes?(node)
            nodes << node
          else
            node.children.each { |children_node| process(children_node) }
          end
        end
      end

      class UndefinedVariablesExtractor < Parser::AST::Processor

        attr_reader :known_variables, :seen_variables

        def initialize(known_variables, seen_variables)
          @known_variables = known_variables
          @seen_variables = seen_variables
        end

        def on_var(node)
          add_seen_var(node)
        end

        def on_vasgn(node)
          add_known_var(node)
        end

        def on_argument(node)
          add_known_var(node)
        end

        private

        def add_seen_var(node)
          seen_variables << node.loc.name.source
          keep_on_processing(node)
        end

        def add_known_var(node)
          known_variables << node.loc.name.source
          keep_on_processing(node)
        end

        def keep_on_processing(node)
          processable_children = node.children.select { |child| child.is_a?(Parser::AST::Node) }
          processable_children.each { |child| process(child) }
        end

      end

    end
  end
end
