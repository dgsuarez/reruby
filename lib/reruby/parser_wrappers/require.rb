module Reruby
  module ParserWrappers
    module Require

      def self.require?(node)
        method_name = node.loc.selector.source
        %w[require require_relative].include?(method_name)
      end

      def self.build(node, appears_in_path)
        required_expr = node.children.last.loc.expression
        required_path = required_expr.source.slice(1..-2)

        Absolute.new(appears_in_path, required_path)
      end

      Base = Struct.new(:appears_in_path, :required_path)

      class Absolute < Base

        def source
          "require '#{required_path}'"
        end

        def source_replacing_namespace(from, to)
          new_path = path_replacing_namespace(from, to)

          "require '#{new_path}'"
        end

        def requires_same_or_nested_namespace?(namespace)
          required_namespace.nested_in_or_same_as?(namespace)
        end

        def requires_namespace?(namespace)
          namespace == required_namespace
        end

        private

        def required_namespace
          Namespace.from_require_path(required_path)
        end

        def path_replacing_namespace(from, to)
          required_path.sub(from.as_require, to.as_require)
        end

      end
    end
  end
end
