module Reruby
  class ExtractMethod::ChangeForInvocationRewriter < Parser::Rewriter

    def initialize(invocation:, text_range:)
      @invocation = invocation
      @text_range = text_range
      @replaced = false
    end

    private

    attr_reader :invocation, :text_range, :replaced

    def process(node)
      if node_in_range?(node)
        replace_or_remove(node)
      else
        super
      end
    end

    def replace_or_remove(node)
      node_range = node.loc.expression
      if replaced
        remove(node_range)
      else
        replace(node_range, invocation)
        @replaced = true
      end
    end

    def node_in_range?(node)
      return false unless node
      node_range = node.loc.expression
      return false unless node_range

      node_text_range = Reruby::TextRange.from_node_range(node_range)

      text_range.includes?(node_text_range)
    end

  end
end
