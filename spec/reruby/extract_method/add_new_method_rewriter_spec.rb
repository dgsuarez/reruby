require 'spec_helper'

describe Reruby::ExtractMethod::AddNewMethodRewriter do

  it "replaces the code in the range with the given invocation" do
    extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
      method_definition: "def extracted(b); end",
      text_range: Reruby::TextRange.parse("4:4:5:10")
    )

    code = <<-CODE.strip_heredoc
      class A
        def something
          a = b
          c = 3
          b
        end

      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      class A
        def something
          a = b
          c = 3
          b
        end

      def extracted(b); end

      end
    CODE

    actual_refactored = inline_refactor(code, extractor)

    expect(actual_refactored).to eql(expected_refactored)
  end

end
