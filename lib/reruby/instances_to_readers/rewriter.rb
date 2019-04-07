module Reruby
  class InstancesToReaders::Rewriter < Parser::TreeRewriter

    def initialize(namespace: '')
      @namespace = Namespace.from_source(namespace)
      @namespace_tracker = Namespace::Tracker.new
      @per_namespace_readers = Hash.new(Set.new)
    end

    def on_module(node)
      open_namespace(node)
    end

    def on_class(node)
      open_namespace(node)
    end

    def on_ivar(node)
      return unless in_namespace_to_change?

      name_node = node.loc.name
      ivar_name = name_node.source
      reader_method = ivar_as_reader(ivar_name)

      readers << reader_method

      replace(name_node, reader_method)
    end

    private

    attr_reader :namespace, :namespace_tracker, :per_namespace_readers

    def open_namespace(node)
      const_node, *content_nodes = node.children
      const_group = ParserWrappers::ConstGroup.from_node_tree(const_node)

      namespace_tracker.open_namespace(const_group.as_namespace) do
        content_nodes.each { |content_node| process(content_node) }
        insert_attr_readers(node) if insert_attr_readers?
      end
    end

    def in_namespace_to_change?
      namespace_tracker.namespace == namespace
    end

    def insert_attr_readers(node)
      indentation = ' ' * (node.loc.column + 2)
      last_const_in_declaration = node.children.take_while { |child| child && child.type == :const }.last
      expression = last_const_in_declaration.loc.expression
      insert_after(expression, "\n\n#{indentation}#{attr_reader_def}\n")
    end

    def insert_attr_readers?
      !readers.empty? && in_namespace_to_change?
    end

    def ivar_as_reader(ivar_name)
      ivar_name.sub('@', '')
    end

    def attr_reader_def
      reader_syms = readers.map { |reader| ":#{reader}" }.join(', ')
      "attr_reader #{reader_syms}"
    end

    def readers
      per_namespace_readers[namespace_tracker.namespace]
    end

  end

end
