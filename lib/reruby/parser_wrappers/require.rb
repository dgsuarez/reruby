module Reruby
  module ParserWrappers
    module Require

      def self.require?(node)
        method_name = node.loc.selector.source
        %w[require require_relative].include?(method_name)
      end

      def self.build(node, _path)
        Absolute.new(node)
      end

      class Base

        def initialize(node)
          @node = node
        end

        def require_method
          node.loc.selector.source
        end

        def source
          node.loc.expression.source
        end

        protected

        attr_reader :node

      end

      class Absolute < Base

        def source_replacing_namespace(from, to)
          new_path = path_replacing_namespace(from, to)

          "#{require_method} '#{new_path}'"
        end

        def nested_in_or_same_as_namespace?(namespace)
          required_namespace.nested_in_or_same_as?(namespace)
        end

        def requires_namespace?(namespace)
          namespace == required_namespace
        end

        private

        def required_namespace
          Namespace.from_require_path(require_path)
        end

        def require_path
          required_expr = node.children.last.loc.expression
          required_expr.source.slice(1..-2)
        end

        def path_replacing_namespace(from, to)
          require_path.sub(from.as_require, to.as_require)
        end

      end
    end
  end
end
