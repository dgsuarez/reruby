module Reruby
  module ParserWrappers
    class CodeRegion

      def initialize(code, text_range)
        @code = code
        @text_range = text_range
      end

      def source
        sources = extracted_region.nodes.map do |node|
          node.loc.expression.source
        end

        sources.join("\n")
      end

      def undefined_variables
        known_variables = Set.new
        seen_variables = Set.new
        extractor = UndefinedVariablesExtractor.new(known_variables, seen_variables)

        extracted_region.nodes.each do |node|
          extractor.process(node)
        end

        (seen_variables - known_variables).to_a
      end

      def includes?(node)
        text_range.includes_node?(node)
      end

      def scope_type
        extracted_region.scope_type
      end

      private

      attr_reader :code, :text_range

      def extracted_region
        @extracted_region ||= begin
                                extractor = RegionExtractor.new(self)
                                extractor.process(parsed_outer_code)
                                extractor
                              end
      end

      def parsed_outer_code
        buffer = Parser::Source::Buffer.new('')
        parser = Parser::CurrentRuby.new
        buffer.source = code
        parser.parse(buffer)
      end

      class RegionExtractor < Parser::AST::Processor

        attr_reader :region, :nodes, :scope_type

        def initialize(region)
          @region = region
          @nodes = []
          @current_scope_type = 'class'
        end

        def on_defs(node)
          old_scope_type = scope_type
          @current_scope_type = 'class'
          super
          @current_scope_type = old_scope_type
        end

        def on_def(node)
          old_scope_type = scope_type
          @current_scope_type = 'method'
          super
          @current_scope_type = old_scope_type
        end

        def process(node)
          return unless node.is_a?(Parser::AST::Node)
          if region.includes?(node)
            @scope_type ||= @current_scope_type
            nodes << node
          else
            super
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
          super
        end

        def on_vasgn(node)
          add_known_var(node)
          super
        end

        def on_argument(node)
          add_known_var(node)
          super
        end

        private

        def add_seen_var(node)
          var_name = node.loc.name.source
          return if var_name =~ /^@/
          seen_variables << var_name
        end

        def add_known_var(node)
          known_variables << node.loc.name.source
        end

      end

    end
  end
end
