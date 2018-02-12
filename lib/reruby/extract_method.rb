module Reruby

  class ExtractMethod

    def initialize(location:, name:, config: Config.default)
      @path, @location = location.split(":", 2)
      @name = name
      @config = config
    end

    def perform
      add_method
      change_invocation

      changed_files = ChangedFiles.new(changed: [path])

      print changed_files.report(format: config.get('report'))
    end

    private

    attr_reader :path, :location, :name, :config, :changed_files

    def add_method
      add_rewriter = AddNewMethodRewriter.new(
        method_definition: method_definition,
        text_range: text_range
      )

      action = Actions::FileRewrite.new(path: path, rewriter: add_rewriter)
      action.perform
    end

    def change_invocation
      change_for_invocation_rewriter = ChangeForInvocationRewriter.new(
        invocation: method_invocation,
        text_range: text_range
      )

      action = Actions::FileRewrite.new(path: path, rewriter: change_for_invocation_rewriter)
      action.perform
    end

    def method_definition
      %(
        def #{name}(#{code_region.undefined_variables})
          #{code_region.source}
        end
      )
    end

    def method_invocation
      "#{name}(#{code_region.undefined_variables})"
    end

    def text_range
      TextRange.parse(location)
    end

    def code_region
      code = File.read(path)
      ParserWrappers::CodeRegion.new(code, text_range)
    end

  end

end
