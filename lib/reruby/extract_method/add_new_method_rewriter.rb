# frozen_string_literal: true

module Reruby
  # :reek:TooManyInstanceVariables
  class ExtractMethod::AddNewMethodRewriter < Parser::TreeRewriter
    def initialize(method_definition:, text_range:)
      @method_definition = method_definition
      @text_range = text_range

      @current_namespace_node = nil
      @global_node = nil
      @containing_namespace = nil
    end

    def on_module(namespace_node)
      @current_namespace_node = namespace_node
      super
      try_to_insert_in_namespace(namespace_node)
    end

    def on_class(namespace_node)
      @current_namespace_node = namespace_node
      super
      try_to_insert_in_namespace(namespace_node)
    end

    private

    attr_reader :method_definition, :text_range, :current_namespace_node, :containing_namespace, :global_node

    def process(node)
      @global_node ||= node
      return if containing_namespace

      if text_range.includes_node?(node)
        @containing_namespace = current_namespace_node
        return
      end

      super

      try_to_insert_in_global_node if node == global_node
    end

    # :reek:ControlParameter
    def try_to_insert_in_namespace(namespace_node)
      return unless namespace_node == containing_namespace

      last_method = containing_namespace.children.last
      insert_after_node(last_method)
    end

    def try_to_insert_in_global_node
      return if containing_namespace

      insert_after_node(global_node)
    end

    def insert_after_node(node)
      insert_after(node.loc.expression, "\n\n#{method_definition}")
    end

  end
end
