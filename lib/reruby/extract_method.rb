module Reruby

  # :reek:TooManyInstanceVariables
  class ExtractMethod < BaseRefactoring

    def prepare(location:, name:)
      @path, @text_range = parse_location(location)
      @name = name
    end

    def refactor
      changed_files.add(changed: [path])
      add_method
      change_invocation
    end

    private

    attr_reader :path, :text_range, :name

    def add_method
      add_rewriter = AddNewMethodRewriter.new(
        method_definition: extracted_method.source,
        text_range: text_range
      )

      action = Actions::FileRewrite.new(path: path, rewriter: add_rewriter)
      action.perform
    end

    def change_invocation
      change_for_invocation_rewriter = ChangeForInvocationRewriter.new(
        invocation: extracted_method.invocation,
        text_range: text_range
      )

      action = Actions::FileRewrite.new(path: path, rewriter: change_for_invocation_rewriter)
      action.perform
    end

    def extracted_method
      @extracted_method ||= begin
                              code = File.read(path)
                              code_region = ParserWrappers::CodeRegion.new(code, text_range)
                              ExtractedMethod.new(
                                name: name,
                                code_region: code_region,
                                keyword_arguments: config.get('extract_method.keyword_arguments')
                              )
                            end
    end

    def parse_location(location)
      path, range_expression = location.split(':', 2)
      [path, TextRange.parse(range_expression)]
    end
  end

end
