require 'spec_helper'

describe Reruby::ExplodeNamespace::AddRequiresRewriter do

  it "adds requires after the one for the original file when found" do

    code = <<-EOF
      require 'a/b'
    EOF

    refactored = <<-EOF
      require 'a/b'
require 'a/b/c'
require 'a/b/d'
    EOF

    rewriter = Reruby::ExplodeNamespace::AddRequiresRewriter.new(
      namespace_to_explode: "A::B",
      namespaces_to_add: ["A::B::C", "A::B::D"]
    )

    actual = inline_refactor(code, rewriter)

    expect(actual).to eq(refactored)
  end

  it "uses the same style of requiring as the original" do
    code = <<-EOF
      require_relative 'a/b'
    EOF

    refactored = <<-EOF
      require_relative 'a/b'
require_relative 'a/b/c'
require_relative 'a/b/d'
    EOF

    rewriter = Reruby::ExplodeNamespace::AddRequiresRewriter.new(
      namespace_to_explode: "A::B",
      namespaces_to_add: ["A::B::C", "A::B::D"]
    )

    actual = inline_refactor(code, rewriter)

    expect(actual).to eq(refactored)
  end

end
