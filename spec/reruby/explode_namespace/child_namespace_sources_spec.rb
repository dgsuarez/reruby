require 'spec_helper'

describe Reruby::ExplodeNamespace::ChildNamespaceSources do

  def namespace(x)
    Reruby::Namespace.new([x])
  end

  def explode(namespace, code)
    exploder = Reruby::ExplodeNamespace::ChildNamespaceSources.new(namespace_to_explode: namespace, code: code)
    exploder.files_to_create
  end

  it "gets the code for the namespaces below the given class" do
    code = <<-EOF
      class A
        class B; end
        module C; end
      end
    EOF

    expected = "class A\nmodule C; end\nend"

    actual = explode("A", code)
    expect(actual["a/c.rb"]).to eq(expected)
  end

  it "gets the code for the namespaces below the given module" do
    code = <<-EOF
      module A
        class B; end
        module C; end
      end
    EOF

    expected = "module A\nclass B; end\nend"

    actual = explode("A", code)

    expect(actual["a/b.rb"]).to eq(expected)
  end

  it "doesn't return the given namespace " do
    code = <<-EOF
      module A
        class B; end
        module C; end
      end
    EOF

    actual = explode("A", code)

    expect(actual["a.rb"]).to be_nil
  end

  it "doesn't return namespaces nested more than 1 level deep" do
    code = <<-EOF
      module A
        class B
          module C; end
        end
      end
    EOF

    actual = explode("A", code)

    expect(actual["a/b/c.rb"]).to be_nil
  end

  it "returns the code of nested namespaces in the 'root'" do
    code = <<-EOF
      module A
        class B
          module C; end
        end
      end
    EOF

    actual = explode("A", code)

    expect(actual["a/b.rb"]).to match(/module C/)
  end

end
