module Reruby
  class ExtractMethod::ExtractedMethod

    def initialize(name:, code_region:)
      @name = name
      @code_region = code_region
    end

    def invocation
      "#{name}(#{params})"
    end

    def source
      "def #{name}(#{params})\n  #{code_region.source}\nend"
    end

    private

    attr_reader :name, :code_region

    def params
      code_region.undefined_variables.join(", ")
    end

  end
end
