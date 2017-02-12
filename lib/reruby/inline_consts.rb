module Reruby
  class InlineConsts

    attr_reader :nodes_in_order

    def self.from_node_tree(node_tree)
      nodes_in_order = reverse_const_tree(node_tree)
      new(nodes_in_order)
    end

    def forced_root?
      nodes_in_order.first.type == :cbase
    end

    def each_const
      seen_consts = []
      nodes_in_order.each do |node|
        seen_consts.push(node.loc.name.source)
        yield(node, seen_consts)
      end
    end

    def without_forced_root
      if forced_root?
        InlineConsts.new(nodes_in_order.slice(1 .. -1))
      else
        self
      end
    end

    def as_source
      const_names = nodes_in_order.map do |node|
        node.loc.name.source
      end

      const_names.join("::")
    end

    private

    def initialize(nodes_in_order)
      @nodes_in_order = nodes_in_order
    end

    def self.reverse_const_tree(node)
      next_node, _ = node.children

      if next_node
        reverse_const_tree(next_node) + [node]
      else
        [node]
      end

    end

  end
end
