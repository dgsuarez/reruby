module Reruby
  # :reek:TooManyInstanceVariables
  class ExtractMethod::AddNewMethodRewriter < Parser::TreeRewriter

    def initialize(method_definition:, text_range:)
      @method_definition = method_definition
      @text_range = text_range
      @current_namespace_node = nil
      @to_insert = nil
    end

    def on_module(namespace_node)
      @current_namespace_node = namespace_node
      super
      try_to_insert(namespace_node)
    end

    def on_class(namespace_node)
      @current_namespace_node = namespace_node
      super
      try_to_insert(namespace_node)
    end

    private

    attr_reader :method_definition, :text_range, :current_namespace_node, :to_insert

    def process(node)
      return if to_insert
      if text_range.includes_node?(node)
        @to_insert = current_namespace_node
        return
      end

      super
    end

    # :reek:ControlParameter
    def try_to_insert(namespace_node)
      return unless namespace_node == to_insert
      last_method = to_insert.children.last
      insert_after(last_method.loc.expression, "\n\n#{method_definition}")
    end

  end
end
