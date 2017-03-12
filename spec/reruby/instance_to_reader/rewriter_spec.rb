require 'spec_helper'

describe Reruby::InstanceToReader::Rewriter do

  def refactor(code, rewriter)
    Reruby::Actions::StringRewrite.new(code, rewriter).perform
  end

  it "gets all the instance vars" do
    rewriter = Reruby::InstanceToReader::Rewriter.new(namespace: "A")

    code = <<-EOF
      class A
        def hi
          "hi " + @person
        end
      end
    EOF

    expected_refactored = <<-EOF
      class A
attr_reader :person

        def hi
          "hi " + person
        end
      end
    EOF

    actual_refactored = refactor(code, rewriter)

    expect(actual_refactored).to eql(expected_refactored)
  end

end

