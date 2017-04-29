module Reruby
  class SourceLocator

    def initialize(code)
      @code = code
    end

    def namespace_containing_line(line)
      def_consts = DefinedConsts.new(code)

      namespaces_with_nodes = def_consts.found.map do |ns, node|
        NamespaceWithNode.new(ns, node)
      end

      best_match = nil

      namespaces_with_nodes.each do |ns_w_node|
        if ns_w_node.better_match_for_line_than?(line, best_match)
          best_match = ns_w_node
        end
      end

      best_match.namespace
    end

    private

    NamespaceWithNode = Struct.new(:namespace, :node) do

      def contains_line?(line)
        (loc.line <= line) &&
          (loc.end.line >= line)
      end

      def better_match_for_line_than?(line, other)
        return false unless contains_line?(line)
        return true unless other

        other_loc = other.loc

        (loc.end.line - loc.line) <
          (other_loc.end.line - other_loc.line)
      end

      def loc
        node.loc
      end

    end

    attr_reader :code

  end
end
