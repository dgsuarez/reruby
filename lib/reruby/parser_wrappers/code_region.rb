module Reruby
  module ParserWrappers
    class CodeRegion

      def initialize(code, region_expression)
        @code = code
        @region = Region.parse(region_expression)
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

      protected

      attr_reader :code, :region

      def inner_nodes
        extractor = RegionExtractor.new(region)
        extractor.process(parsed_outer_code)
        extractor.nodes
      end

      def parsed_outer_code
        buffer = Parser::Source::Buffer.new('')
        parser = Parser::CurrentRuby.new
        buffer.source = code
        parser.parse(buffer)
      end

      class Region

        attr_reader :start_line, :start_col, :end_line, :end_col

        def self.parse(region_expression)
          params = region_expression.split(":").map(&:to_i)
          new(*params)
        end

        def self.from_node_range(node_range)
          new(node_range.line,
              node_range.column,
              node_range.last_line,
              node_range.last_column)
        end

        def initialize(start_line, start_col, end_line, end_col)
          @start_line = start_line
          @start_col = start_col
          @end_line = end_line
          @end_col = end_col
        end

        def node_inside?(node)
          node_range = node.loc.expression
          return false unless node_range
          node_region = Region.from_node_range(node_range)

          starts_before?(node_region) && ends_after?(node_region)
        end

        protected

        def starts_before?(other_region)
          other_start_line = other_region.start_line

          if start_line == other_start_line
            start_col <= other_region.start_col
          else
            start_line < other_start_line
          end
        end

        def ends_after?(other_region)
          other_end_line = other_region.end_line

          if end_line == other_end_line
            end_col >= other_end_line
          else
            end_line > other_end_line
          end
        end
      end

      class RegionExtractor

        attr_reader :region, :nodes

        def initialize(region)
          @region = region
          @nodes = []
        end

        def process(node)
          return unless node.is_a?(Parser::AST::Node)
          if region.node_inside?(node)
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
          see_var(node)
        end

        def on_vasgn(node)
          know_var(node)
        end

        def on_argument(node)
          know_var(node)
        end

        private

        def see_var(node)
          seen_variables << node.loc.name.source
          keep_on_processing(node)
        end

        def know_var(node)
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
