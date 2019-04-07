module Reruby
  class ExtractMethod::ExtractedMethod

    def initialize(name:, code_region:, keyword_arguments:)
      @name = name
      @code_region = code_region
      @keyword_arguments = keyword_arguments
    end

    def invocation
      "#{assignment}#{name}(#{args.invocation})"
    end

    def source
      "def #{scope_modifier}#{name}(#{args.arguments})\n  #{inner_source}\nend"
    end

    private

    attr_reader :name, :code_region, :keyword_arguments

    def last_node
      code_region.nodes.last
    end

    def last_assignment?
      last_node.type == :lvasgn
    end

    def assignment
      return '' unless last_assignment?

      "#{last_node.children.first} = "
    end

    def last_node_for_source
      if last_assignment?
        last_node.children.last
      else
        last_node
      end
    end

    def inner_source
      nodes = code_region.nodes.slice(0..-2) + [last_node_for_source]

      sources = nodes.map do |node|
        node.loc.expression.source
      end

      sources.join("\n")
    end

    def scope_modifier
      if code_region.scope_type == 'class'
        'self.'
      else
        ''
      end
    end

    def undefined_variables
      extractor = Reruby::ExtractMethod::UndefinedVariablesExtractor.new

      extractor.undefined_variables_in_region(code_region)
    end

    def args
      if keyword_arguments
        KeywordArgs.new(undefined_variables)
      else
        PositionalArgs.new(undefined_variables)
      end
    end

    Args = Struct.new(:vars)

    class KeywordArgs < Args
      def invocation
        vars.map { |var| "#{var}: #{var}" }.join(', ')
      end

      def arguments
        vars.map { |var| "#{var}: " }.join(', ')
      end

    end

    class PositionalArgs < Args
      def invocation
        vars.join(', ')
      end

      def arguments
        invocation
      end
    end

  end
end
