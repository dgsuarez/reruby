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

    attr_reader :inserted, :in_range, :method_definition, :text_range

    def process(node)
      @in_range ||= text_range.includes_node?(node)
      super
    end

    def insert_definition_when_in_range(node)
      return if inserted || !in_range
      @inserted = true
      last_method = node.children.last
      insert_after(last_method.loc.expression, "\n\n#{method_definition}")
    end

  end
end
