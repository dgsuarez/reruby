require 'spec_helper'

describe Reruby::RenameConst::UsageRewriter do

  it "changes the requires for the given namespace" do
    renamer = Reruby::RenameConst::RequireRewriter.new(from: "A", to: "Z")

    code = <<-EOF
      require 'a'
    EOF

    expected_refactored = <<-EOF
      require 'z'
    EOF

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "doesn't change the requires for other namespaces" do
    renamer = Reruby::RenameConst::RequireRewriter.new(from: "A", to: "Z")

    code = <<-EOF
      require 'j'
    EOF

    expected_refactored = <<-EOF
      require 'j'
    EOF

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "changes namespaces with multiple consts" do
    renamer = Reruby::RenameConst::RequireRewriter.new(from: "A::B", to: "Z")

    code = <<-EOF
      require 'a/b'
    EOF

    expected_refactored = <<-EOF
      require 'a/z'
    EOF

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "changes namespaces dangling from the given one" do
    renamer = Reruby::RenameConst::RequireRewriter.new(from: "A::B", to: "Z")

    code = <<-EOF
      require 'a/b/c'
    EOF

    expected_refactored = <<-EOF
      require 'a/z/c'
    EOF

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "doesn't change unrelated requires containing the original const name" do
    renamer = Reruby::RenameConst::RequireRewriter.new(from: "Log", to: "SuperLog")

    code = <<-EOF
      require 'logger'
    EOF

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(code)
  end

  it "doesn't change unrelated multi-level requires containing the original const name" do
    renamer = Reruby::RenameConst::RequireRewriter.new(from: "Super::Log", to: "SuperLog")

    code = <<-EOF
      require 'super/logger'
    EOF

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(code)
  end
end
