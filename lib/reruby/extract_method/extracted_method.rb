module Reruby
  class ExtractMethod::ExtractedMethod

    def initialize(name:, code_region:, keyword_arguments:)
      @name = name
      @code_region = code_region
      @keyword_arguments = keyword_arguments
    end

    def invocation
      "#{name}(#{args.invocation})"
    end

    def source
      "def #{scope_modifier}#{name}(#{args.arguments})\n  #{code_region.source}\nend"
    end

    private

    attr_reader :name, :code_region, :keyword_arguments

    def scope_modifier
      if code_region.scope_type == "class"
        "self."
      else
        ""
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
        vars.map { |var| "#{var}: #{var}" }.join(", ")
      end

      def arguments
        vars.map { |var| "#{var}: " }.join(", ")
      end

    end

    class PositionalArgs < Args
      def invocation
        vars.join(", ")
      end

      def arguments
        invocation
      end
    end

  end
end
