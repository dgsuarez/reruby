module Reruby
  class InstanceToReader::Rewriter < Parser::Rewriter

    def initialize(namespace: "")
      @namespace = Namespace.from_source(namespace)
      @namespace_tracker = NamespaceTracker.new
      reset_readers
    end

    def on_module(node)
      open_namespace(node)
    end

    def on_class(node)
      open_namespace(node)
    end

    def on_ivar(node)
      ivar_name = node.loc.name.source
      reader_method = ivar_as_reader(ivar_name)

      readers << reader_method

      replace(node.loc.name, reader_method)
    end

    private

    attr_reader :namespace, :namespace_tracker, :readers

    def open_namespace(node)
      const_node, *content_nodes = node.children
      inline_consts = InlineConsts.from_node_tree(const_node)

      namespace_tracker.open_namespace(inline_consts) do
        reset_readers
        content_nodes.each { |n| process(n) }
      end

      insert_after(const_node.loc.name, "\n#{attr_reader_def}\n")
    end

    def ivar_as_reader(ivar_name)
      ivar_name.sub("@", "")
    end

    def attr_reader_def
      reader_syms = readers.map { |reader| ":#{reader}"}.join(", ")
      "attr_reader #{reader_syms}"
    end

    def reset_readers
      @readers = Set.new()
    end

  end

end
