# frozen_string_literal: true

require 'spec_helper'

describe Reruby::RenameConst::UsageRewriter do

  it 'changes the requires for the given namespace' do
    renamer = Reruby::RenameConst::RequireRewriter.new(path: 'lib/a.rb', from: 'A', to: 'Z')

    code = <<-CODE
      require 'a'
    CODE

    expected_refactored = <<-CODE
      require 'z'
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "doesn't change the requires for other namespaces" do
    renamer = Reruby::RenameConst::RequireRewriter.new(path: 'lib/a.rb', from: 'A', to: 'Z')

    code = <<-CODE
      require 'j'
    CODE

    expected_refactored = <<-CODE
      require 'j'
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'changes namespaces with multiple consts' do
    renamer = Reruby::RenameConst::RequireRewriter.new(path: 'lib/a/b.rb', from: 'A::B', to: 'Z')

    code = <<-CODE
      require 'a/b'
    CODE

    expected_refactored = <<-CODE
      require 'a/z'
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'changes namespaces dangling from the given one' do
    renamer = Reruby::RenameConst::RequireRewriter.new(path: 'lib/a/b.rb', from: 'A::B', to: 'Z')

    code = <<-CODE
      require 'a/b/c'
    CODE

    expected_refactored = <<-CODE
      require 'a/z/c'
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "doesn't change unrelated requires containing the original const name" do
    renamer = Reruby::RenameConst::RequireRewriter.new(path: 'lib/log.rb', from: 'Log', to: 'SuperLog')

    code = <<-CODE
      require 'logger'
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(code)
  end

  it "doesn't change unrelated multi-level requires containing the original const name" do
    renamer = Reruby::RenameConst::RequireRewriter.new(path: 'lib/super/log.rb', from: 'Super::Log', to: 'SuperLog')

    code = <<-CODE
      require 'super/logger'
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(code)
  end
end
