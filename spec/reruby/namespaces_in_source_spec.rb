# frozen_string_literal: true

require 'spec_helper'

describe Reruby::NamespacesInSource do

  it 'gets the definitions for non-complex stuff in the code' do
    code = <<-CODE
      class A
        def c
        end
      end
    CODE

    definitions = Reruby::NamespacesInSource.new(code)

    expected_namespaces = [
      namespace(%w[A])
    ]

    expect(definitions.namespaces).to eq expected_namespaces
  end

  it 'gets the definitions for nested structures' do
    code = <<-CODE
      class A
        def c
        end

        class B
        end
      end
    CODE

    definitions = Reruby::NamespacesInSource.new(code)

    expected_namespaces = [
      namespace(%w[A]),
      namespace(%w[A B])
    ]

    expect(definitions.namespaces).to eq expected_namespaces
  end

  it 'gets for both classes & modules' do
    code = <<-CODE
      module A
        def c
        end

        class B
        end
      end
    CODE

    definitions = Reruby::NamespacesInSource.new(code)

    expected_namespaces = [
      namespace(%w[A]),
      namespace(%w[A B])
    ]

    expect(definitions.namespaces).to eq expected_namespaces
  end

  it 'knows gets the nodes for each namespace' do
    code = <<-CODE
      class A
        def c
        end

        module B
          a
        end
      end
    CODE

    definitions = Reruby::NamespacesInSource.new(code)
    source = definitions.parser_node_for_namespace(namespace(%w[A B])).loc.expression.source

    expect(source).to match(/module B/)
  end

end
