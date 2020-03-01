# frozen_string_literal: true

require 'spec_helper'

describe Reruby::RenameConst::UsageRewriter do

  it 'renames the given constant in the given code' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A', to: 'Z')

    code = <<~CODE
      A.new
      B.new
      c = A.done!
    CODE

    expected_refactored = <<~CODE
      Z.new
      B.new
      c = Z.done!
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'ignores code from other namespaces' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A', to: 'Z')

    code = <<~CODE
      c = J::A.done!
    CODE

    expected_refactored = <<~CODE
      c = J::A.done!
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'replaces qualified class names' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A::B', to: 'Z')

    code = <<~CODE
      c = A::B.done!
    CODE

    expected_refactored = <<~CODE
      c = A::Z.done!
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)

  end

  it 'can rename when using :: roots' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A::B', to: 'Z')

    code = <<~CODE
      class J
        c = ::A::B.done!
      end
    CODE

    expected_refactored = <<~CODE
      class J
        c = ::A::Z.done!
      end
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "doesn't rename if the root namespace makes it not match" do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'J::A::B', to: 'Z')

    code = <<~CODE
      class J
        c = ::A::B.done!
      end
    CODE

    expected_refactored = <<~CODE
      class J
        c = ::A::B.done!
      end
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)

  end

  it "doesn't rename root namespaces when names are repeated" do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A::A', to: 'Z')

    code = <<~CODE
      class A

        module A
        end

        module B
          def something
            ::A
          end
        end
      end
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to match(/class A/)
    expect(actual_refactored).to match(/module Z/)
    expect(actual_refactored).to match(/::A/)
  end

  it 'is aware of the full external namespace of class & modules  where the class is used' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A::B::C', to: 'Z')

    code = <<~CODE
      module A
        class B
          C.new
        end

        class J
          C.new
        end
      end
    CODE

    expected_refactored = <<~CODE
      module A
        class B
          Z.new
        end

        class J
          C.new
        end
      end
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'substitutes according to the inline namespace that was present' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A::B', to: 'Z')

    code = <<~CODE
      A::B.new
    CODE

    expected_refactored = <<~CODE
      A::Z.new
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)

  end

  it 'renames class definitions' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A::B', to: 'Z')

    code = <<~CODE
      module A
        class B
        end
      end
    CODE

    expected_refactored = <<~CODE
      module A
        class Z
        end
      end
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'renames nodes in the middle of inline definitions' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A::B', to: 'Z')

    code = <<~CODE
      module A::B::C
        class J
        end
      end
    CODE

    expected_refactored = <<~CODE
      module A::Z::C
        class J
        end
      end
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'does all of them at the same time' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A::B', to: 'Z')

    code = <<~CODE
      module A
        B.new

        class C
          def is_it?
            B.is_a?(Z::B)
          end
        end

        class B

        end

      end

      A::B.new
    CODE

    expected_refactored = <<~CODE
      module A
        Z.new

        class C
          def is_it?
            Z.is_a?(Z::B)
          end
        end

        class Z

        end

      end

      A::Z.new
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'renames for itself' do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'Reruby::Scope', to: 'Namespace')

    code = <<~CODE
      module Reruby
        class RenameConst::Rewriter < Parser::Rewriter

          def initialize(from: "", to: "")
            @from_namespace = Scope.new(from.split("::"))
            @namespace_tracker = Namespace::Tracker.new
            @to = to
          end
        end
      end
    CODE

    expected_refactored = <<~CODE
      module Reruby
        class RenameConst::Rewriter < Parser::Rewriter

          def initialize(from: "", to: "")
            @from_namespace = Namespace.new(from.split("::"))
            @namespace_tracker = Namespace::Tracker.new
            @to = to
          end
        end
      end
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "doesn't break nor refactors variable const groups" do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'C', to: 'Z')

    code = <<~CODE
      module A
        class B

          def hi(parameter)
            parameter::C
            some_method::C
          end

          C.new

        end
      end
    CODE

    expected_refactored = <<~CODE
      module A
        class B

          def hi(parameter)
            parameter::C
            some_method::C
          end

          Z.new

        end
      end
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "doesn't replace when the some parent of the namespace is used inside it" do
    renamer = Reruby::RenameConst::UsageRewriter.new(from: 'A::B', to: 'Z')

    code = <<~CODE
      module A::B
        A
      end
    CODE

    expected_refactored = <<~CODE
      module A::Z
        A
      end
    CODE

    actual_refactored = inline_refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

end
