module Reruby

  # :reek:TooManyInstanceVariables
  class ExtractMethod

    def initialize(location:, name:, config: Config.default)
      @path, @text_range = parse_location(location)
      @name = name
      @config = config
      @changed_files = ChangedFiles.new(changed: [path])
    end

    def perform
      autocommit

      add_method
      change_invocation

      autofix
      print_report
    end

    private

    attr_reader :path, :text_range, :name, :config, :changed_files

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
                                keyword_arguments: config.get("extract_method.keyword_arguments")
                              )
                            end
    end

    def parse_location(location)
      path, range_expression = location.split(":", 2)
      [path, TextRange.parse(range_expression)]
    end

    def print_report
      print changed_files.report(format: config.get('report'))
    end

    def autofix
      RubocopAutofix.new(changed_files).clean if config.get('rubocop_autofix')
    end

    def autocommit
      GitAutocommit.new.autocommit(config.get('autocommit-message')) if config.get('autocommit')
    end
  end

end
