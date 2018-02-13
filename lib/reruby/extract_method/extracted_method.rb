module Reruby
  class ExtractMethod::ExtractedMethod

    # :reek:BooleanParameter
    def initialize(name:, code_region:, keyword_arguments: false)
      @name = name
      @code_region = code_region
      @keyword_arguments = keyword_arguments
    end

    def invocation
      "#{name}(#{params})"
    end

    def source
      "def #{name}(#{params})\n  #{code_region.source}\nend"
    end

    private

    attr_reader :name, :code_region, :keyword_arguments

    def params
      undefined_vars = code_region.undefined_variables
      args = if keyword_arguments
               undefined_vars.map { |var| "#{var}: #{var}" }
             else
               undefined_vars
             end
      args.join(", ")
    end

  end
end
