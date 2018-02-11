module Reruby
  class ExplodeNamespace::ChildrenNamespaceFiles

    def initialize(namespace_to_explode: "", code: "", root_path: nil)
      @namespace_to_explode = Namespace.from_source(namespace_to_explode)
      @namespaces_in_source = NamespacesInSource.new(code)
      @root_path = root_path
    end

    def files_to_create
      namespaces.map do |namespace|
        old_source = namespaces_in_source.parser_node_for_namespace(namespace)
        new_source = envelop_in_namespace(old_source)

        [const_path(namespace), new_source]
      end.to_h
    end

    def namespaces
      namespaces_in_source.namespaces.select do |namespace|
        namespace.nested_one_level_in?(namespace_to_explode)
      end
    end

    private

    attr_reader :namespace_to_explode, :namespaces_in_source, :root_path

    def const_path(const)
      const_relative_path = const.relative_path
      if root_path
        File.join(root_path, const_relative_path)
      else
        const_relative_path
      end
    end

    def envelop_in_namespace(source_node)
      "#{namespace_declaration}\n#{source_node.loc.expression.source}\nend"
    end

    def namespace_declaration
      namespace_type = namespaces_in_source.parser_node_for_namespace(namespace_to_explode).type
      "#{namespace_type} #{namespace_to_explode.as_source}"
    end

  end
end
