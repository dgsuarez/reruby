module Reruby
  # :reek:TooManyInstanceVariables
  class ExtractMethod::AddNewMethodRewriter < Parser::Rewriter

    def initialize(method_definition:, text_range:)
      @method_definition = method_definition
      @text_range = text_range
      @inserted = false
      @in_range = false
    end

    def on_module(node)
      super
      insert_definition_when_in_range(node)
    end

    def on_class(node)
      super
      insert_definition_when_in_range(node)
    end

    private

    attr_reader :method_definition, :text_range, :namespace_tracker

    def process(node)
      @in_range = node_in_range?(node)
      super
    end

    def insert_definition_when_in_range(node)
      return if @inserted || !@in_range
      @inserted = true
      last_method = node.children.last
      insert_after(last_method.loc.expression, "\n\n#{method_definition}")
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
