# frozen_string_literal: true

module Reruby
  module ParserWrappers
    class CodeRegion

      def initialize(code, text_range)
        @code = code
        @text_range = text_range
      end

      def includes?(node)
        text_range.includes_node?(node)
      end

      def scope_type
        extracted_region.scope_type
      end

      def nodes
        extracted_region.nodes
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
          @current_scope_type = 'global'
        end

        def on_class(node)
          old_scope_type = scope_type
          @current_scope_type = 'class'
          super
          @current_scope_type = old_scope_type
        end

        def on_module(node)
          old_scope_type = scope_type
          @current_scope_type = 'class'
          super
          @current_scope_type = old_scope_type
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
    end
  end
end
