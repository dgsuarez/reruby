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
        method_name = node.loc.selector.source

        actual_class = method_name == 'require_relative' ? Relative : Absolute

        actual_class.new(appears_in_path, required_path)
      end

      class Base

        def initialize(appears_in_path, required_path)
          @appears_in_path = appears_in_path
          @required_path = required_path
        end

        def source
          "#{require_method} '#{required_path}'"
        end

        def source_replacing_namespace(from, to)
          new_path = path_replacing_namespace(from, to)

          "#{require_method} '#{new_path}'"
        end

        def requires_same_or_nested_namespace?(namespace)
          required_namespace.nested_in_or_same_as?(namespace)
        end

        def requires_namespace?(namespace)
          namespace == required_namespace
        end

        protected

        attr_reader :appears_in_path, :required_path

        def required_namespace
          Namespace.from_require_path(absolute_required_path)
        end

        def absolute_required_path_replacing_namespace(from, to)
          absolute_required_path.sub(from.as_require, to.as_require)
        end

      end

      class Absolute < Base
        def require_method
          'require'
        end

        protected

        def path_replacing_namespace(from, to)
          absolute_required_path_replacing_namespace(from, to)
        end

        def absolute_required_path
          required_path
        end

      end

      class Relative < Base

        def require_method
          'require_relative'
        end

        protected

        def path_replacing_namespace(from, to)
          new_absolute_path = absolute_required_path_replacing_namespace(from, to)

          current_dir_pathname = Pathname.new(appears_in_dir)
          new_absolute_pathname = Pathname.new(new_absolute_path)

          new_absolute_pathname.relative_path_from(current_dir_pathname).to_s
        end

        def absolute_required_path
          require_with_dir_jumps = File.join("/", appears_in_dir, required_path)

          full_require = File.expand_path(require_with_dir_jumps).slice(1..-1)

          full_require.sub(%r{^(lib|app/.+?)/}, '')
        end

        def appears_in_dir
          File.dirname(appears_in_path)
        end

      end
    end
  end
end
