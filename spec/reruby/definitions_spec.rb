require 'spec_helper'

describe Reruby::Definitions do

  it "gets the definitions for non-complex stuff in the code" do
    code = <<-EOF
      class A
        def c
        end
      end
    EOF

    definitions = Reruby::Definitions.new(code)

    expected_scopes = [
      Reruby::Scope.new(%w(A)),
    ]

    expect(definitions.scopes).to eq expected_scopes
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

    definitions = Reruby::Definitions.new(code)

    expected_scopes = [
      Reruby::Scope.new(%w(A)),
      Reruby::Scope.new(%w(A B)),
    ]

    expect(definitions.scopes).to eq expected_scopes
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

    definitions = Reruby::Definitions.new(code)

    expected_scopes = [
      Reruby::Scope.new(%w(A)),
      Reruby::Scope.new(%w(A B)),
    ]

    expect(definitions.scopes).to eq expected_scopes
  end

  it "knows gets the nodes for each scope" do
    code = <<-EOF
      class A
        def c
        end

        module B
          a
        end
      end
    EOF

    definitions = Reruby::Definitions.new(code)
    source = definitions.found[Reruby::Scope.new(%w(A B))].loc.expression.source

    expect(source).to match(/module B/)
  end

end
