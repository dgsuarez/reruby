# frozen_string_literal: true

module Reruby
  class SourceLocator

    def self.namespace_in_location(location)
      path, range_expression = location.split(':', 2)
      text_range = TextRange.parse(range_expression)

      code = File.read(path)

      new(code).namespace_containing_line(text_range.start_line)
    end

    def initialize(code)
      @code = code
    end

    def namespace_containing_line(line)
      best_match = nil

      namespaces_with_node.each do |ns_w_node|
        best_match = ns_w_node if ns_w_node.better_match_for_line_than?(line, best_match)
      end

      best_match.namespace
    end

    private

    attr_reader :code

    # :reek:FeatureEnvy makes more sense as a private method here
    def namespaces_with_node
      namespaces_in_source = NamespacesInSource.new(code)

      namespaces_in_source.namespaces.map do |namespace|
        parser_node = namespaces_in_source.parser_node_for_namespace(namespace)
        ParserWrappers::NamespaceWithNode.new(namespace, parser_node)
      end
    end

  end
end
