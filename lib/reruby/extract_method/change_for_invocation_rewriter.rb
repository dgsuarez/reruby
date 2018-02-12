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
      if text_range.includes_node?(node)
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

  end
end
