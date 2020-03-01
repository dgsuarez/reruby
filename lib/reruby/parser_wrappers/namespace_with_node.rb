# frozen_string_literal: true

module Reruby
  module ParserWrappers
    class NamespaceWithNode

      attr_reader :namespace, :node

      def initialize(namespace, node)
        @namespace = namespace
        @node = node
      end

      def contains_line?(line)
        (loc.line <= line) &&
          (loc.end.line >= line)
      end

      def better_match_for_line_than?(line, other)
        return false unless contains_line?(line)
        return true unless other

        line_count < other.line_count
      end

      def loc
        node.loc
      end

      def line_count
        loc.end.line - loc.line
      end

    end
  end
end
