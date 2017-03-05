module Reruby
  class ExplodeNamespace::ChildNamespaceSources

    def initialize(namespace_to_explode, code)
      @namespace_to_explode = Namespace.from_source(namespace_to_explode)
      @defined_consts = DefinedConsts.new(code)
    end

    def sources
      namespaces_to_extract.map do |const, source_node|
        new_source = envelop_in_namespace(source_node)
        [const, new_source]
      end.to_h
    end

    private

    attr_reader :namespace_to_explode, :defined_consts

    def namespaces_to_extract
      defined_consts.found.select do |const, _|
        nesting_level = const.nesting_level_in(namespace_to_explode)
        nesting_level == 1
      end
    end

    def envelop_in_namespace(source_node)
      namespace_declaration + "\n" +
        source_node.loc.expression.source + "\n" +
        "end"
    end

    def namespace_declaration
      namespace_type = defined_consts.found[namespace_to_explode].type
      "#{namespace_type} #{namespace_to_explode.as_source}"
    end

  end
end
