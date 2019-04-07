
module Reruby
  class RenameConst::UsageRewriter < Parser::TreeRewriter

    def initialize(from: "", to: "")
      @from_namespace = Namespace.from_source(from).relativize
      @namespace_tracker = Namespace::Tracker.new
      @to = to
    end

    def on_module(node)
      open_namespace(node)
    end

    def on_class(node)
      open_namespace(node)
    end

    def on_const(node)
      const_group = ParserWrappers::ConstGroup.from_node_tree(node)
      process_const_group(const_group)
    rescue StandardError
      node_source = node.loc.expression.source
      Reruby.logger.warn "Saw \`#{node_source}\`, ignoring"
    end

    private

    attr_reader :from_namespace, :to, :namespace_tracker

    def process_const_group(const_group)
      const_group.each_sub_const_group do |sub_const_group|
        current_node = sub_const_group.last_node
        rename(current_node) if match?(sub_const_group)
      end
    end

    def open_namespace(node)
      const_node, *content_nodes = node.children
      const_group = ParserWrappers::ConstGroup.from_node_tree(const_node)

      process_const_group(const_group)

      namespace_tracker.open_namespace(const_group.as_namespace) do
        content_nodes.each do |content_node|
          process(content_node)
        end
      end
    end

    def rename(node)
      replace(node.loc.name, to)
    end

    def match?(const_group)
      current_namespace = namespace_tracker.namespace.adding(const_group.as_namespace)
      current_namespace.can_resolve_to?(from_namespace)
    end

  end

end
