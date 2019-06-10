module Reruby
  # :reek:TooManyInstanceVariables
  class ExtractMethod::AddNewMethodRewriter < Parser::TreeRewriter
    def initialize(method_definition:, text_range:, destination: nil)
      @method_definition = method_definition
      @text_range = text_range
      @destination = destination

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

    attr_reader :method_definition, :text_range, :current_namespace_node, :containing_namespace, :global_node, :destination

    def process(node)
      @global_node ||= node
      return if containing_namespace

      node_name = find_node_name(current_namespace_node.to_s)

      insert_in_same_nodespace = (!destination and text_range.includes_node?(node))

      if (node_name == destination) or insert_in_same_nodespace
        @containing_namespace = current_namespace_node
        return
      end

      super

      try_to_insert_in_global_node if node == global_node
    end

    def find_node_name(string_node)
      return false unless string_node.length > 0
      start_index = string_node[0..6].include?("module") ? 22 : 21
      end_index = string_node[start_index..-1].index(')') + start_index - 1
      return string_node[start_index..end_index]
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
