# frozen_string_literal: true

module Reruby
  class ExtractMethod

    class UndefinedVariablesExtractor < Parser::AST::Processor

      def initialize
        @known_variables = Set.new
        @seen_variables = Set.new
      end

      def undefined_variables_in_region(code_region)
        code_region.nodes.each do |node|
          process(node)
        end

        (seen_variables - known_variables).to_a
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

      attr_reader :known_variables, :seen_variables

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
