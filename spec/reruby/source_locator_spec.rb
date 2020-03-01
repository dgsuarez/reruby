# frozen_string_literal: true

require 'spec_helper'

describe Reruby::SourceLocator do

  def namespace_for_line(code, line)
    locator = Reruby::SourceLocator.new(code)
    locator.namespace_containing_line(line)
  end

  let(:complex_code) do
    %(
      class A

        class B
        end

        class C
          def hi
            "hi"
          end
        end

      end
    )
  end

  it 'gets the class containing the given line for a simple class' do

    code = <<-CODE
      class A

        def hi
          "hi"
        end

      end

    CODE

    expected = namespace(%w[A])
    actual = namespace_for_line(code, 4)

    expect(actual).to eq(expected)
  end

  it 'gets the class containing the given line for nested scenarios' do
    expected = namespace(%w[A C])
    actual = namespace_for_line(complex_code, 7)

    expect(actual).to eq(expected)
  end

  it 'gets the class containing the given line for the closing of a class' do
    expected = namespace(%w[A])
    actual = namespace_for_line(complex_code, 12)

    expect(actual).to eq(expected)
  end

end
