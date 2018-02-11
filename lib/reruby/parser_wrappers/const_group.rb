module Reruby
  module ParserWrappers
    class ConstGroup

      attr_reader :nodes_in_order

      class << self

        def from_node_tree(node_tree)
          nodes_in_order = reverse_const_tree(node_tree)
          new(nodes_in_order)
        end

        private

        def reverse_const_tree(node)
          raise "Can't handle non-static groups" unless %i[const cbase].include?(node.type)

          next_node, = node.children

          if next_node
            reverse_const_tree(next_node) + [node]
          else
            [node]
          end
        end
      end

      def each_sub_const_group
        seen_consts = []
        nodes_in_order.each do |node|
          seen_consts.push(node)
          inline_until_me = self.class.new(seen_consts)
          yield(inline_until_me)
        end
      end

      def as_namespace
        if forced_root?
          Namespace::Root.new(const_names)
        else
          Namespace::Absolute.new(const_names)
        end
      end

      def last_node
        nodes_in_order.last
      end

      private

      def initialize(nodes_in_order)
        @nodes_in_order = nodes_in_order
      end

      def forced_root?
        !nodes_in_order.empty? &&
          nodes_in_order.first.type == :cbase
      end

      def const_names
        name_nodes = if forced_root?
                       nodes_in_order.slice(1..-1)
                     else
                       nodes_in_order
                     end
        name_nodes.map { |node| node.loc.name.source }
      end

    end
  end
end
