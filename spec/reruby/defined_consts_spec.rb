require 'spec_helper'

describe Reruby::DefinedConsts do

  it "gets the definitions for non-complex stuff in the code" do
    code = <<-EOF
      class A
        def c
        end
      end
    EOF

    definitions = Reruby::DefinedConsts.new(code)

    expected_namespaces = [
      Reruby::Namespace.new(%w(A)),
    ]

    expect(definitions.namespaces).to eq expected_namespaces
  end

  it "gets the definitions for nested structures" do
    code = <<-EOF
      class A
        def c
        end

        class B
        end
      end
    EOF

    definitions = Reruby::DefinedConsts.new(code)

    expected_namespaces = [
      Reruby::Namespace.new(%w(A)),
      Reruby::Namespace.new(%w(A B)),
    ]

    expect(definitions.namespaces).to eq expected_namespaces
  end

  it "gets for both classes & modules" do
    code = <<-EOF
      module A
        def c
        end

        class B
        end
      end
    EOF

    definitions = Reruby::DefinedConsts.new(code)

    expected_namespaces = [
      Reruby::Namespace.new(%w(A)),
      Reruby::Namespace.new(%w(A B)),
    ]

    expect(definitions.namespaces).to eq expected_namespaces
  end

  it "knows gets the nodes for each namespace" do
    code = <<-EOF
      class A
        def c
        end

        module B
          a
        end
      end
    EOF

    definitions = Reruby::DefinedConsts.new(code)
    source = definitions.found[Reruby::Namespace.new(%w(A B))].loc.expression.source

    expect(source).to match(/module B/)
  end

end
