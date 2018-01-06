require 'spec_helper'

describe Reruby::ExplodeNamespace::MainFileRewriter do

  it "should remove children namespaces" do
    code = <<-EOF
      class A
        class B

        end

        module C

        end
      end
    EOF

    rewriter = Reruby::ExplodeNamespace::MainFileRewriter.new(namespace_to_explode: "A")

    actual = inline_refactor(code, rewriter)

    expect(actual).to_not match(/class B/)
    expect(actual).to_not match(/module C/)
  end

  it "should leave methods and others around" do
    code = <<-EOF
      class A

        def hi; end
        class B; end

        def bye; end
        attr_reader :bu

        module C; end

      end
    EOF

    rewriter = Reruby::ExplodeNamespace::MainFileRewriter.new(namespace_to_explode: "A")

    actual = inline_refactor(code, rewriter)

    expect(actual).to match(/def hi/)
    expect(actual).to match(/def bye/)
    expect(actual).to match(/attr_reader :bu/)
  end

end
