# frozen_string_literal: true

require 'spec_helper'

describe Reruby::ExtractMethod::ChangeForInvocationRewriter do

  it 'replaces the code in the range with the given invocation' do
    extractor = Reruby::ExtractMethod::ChangeForInvocationRewriter.new(
      invocation: 'extracted(b)',
      text_range: Reruby::TextRange.parse('4:4:5:10')
    )

    code = <<~CODE
      class A
        def something
          a = b
          c = 3
          b
        end
      end
    CODE

    expected_refactored_regex = /a = b\n\s+extracted\(b\)\n\s+end/m

    actual_refactored = inline_refactor(code, extractor)

    expect(actual_refactored).to match(expected_refactored_regex)
  end

end
