require 'spec_helper'

describe Reruby::InstanceToReader::Rewriter do

  it "gets all the instance vars" do
    rewriter = Reruby::InstanceToReader::Rewriter.new(namespace: "A")

    code = <<-CODE.strip_heredoc
      class A
        def hi
          "hi " + @person
        end
      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      class A
      attr_reader :person

        def hi
          "hi " + person
        end
      end
    CODE

    actual_refactored = inline_refactor(code, rewriter)

    expect(actual_refactored).to eql(expected_refactored)
  end

end
