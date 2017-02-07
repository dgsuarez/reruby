require 'spec_helper'

describe Reruby::RenameConst::Rewriter do

  def refactor(code, renamer)
    Reruby::StringRewriteAction.new(code, renamer).perform
  end

  it "renames the given constant in the given code" do
    renamer = Reruby::RenameConst::Rewriter.new(from:"A", to:"Z")

    code = <<-EOF
      A.new
      B.new
      c = A.done!
    EOF

    expected_refactored = <<-EOF
      Z.new
      B.new
      c = Z.done!
    EOF

    actual_refactored = refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "ignores code from other namespaces" do
    renamer = Reruby::RenameConst::Rewriter.new(from:"A", to:"Z")

    code = <<-EOF
      c = J::A.done!
    EOF

    expected_refactored = <<-EOF
      c = J::A.done!
    EOF

    actual_refactored = refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "replaces qualified class names" do
    renamer = Reruby::RenameConst::Rewriter.new(from:"A::B", to:"Z")

    code = <<-EOF
      c = A::B.done!
    EOF

    expected_refactored = <<-EOF
      c = A::Z.done!
    EOF

    actual_refactored = refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)

  end

  it "is aware of the full external namespace of class & modules  where the class is used" do
    renamer = Reruby::RenameConst::Rewriter.new(from:"A::B::C", to:"Z")

    code = <<-EOF
      module A
        class B
          C.new
        end

        class J
          C.new
        end
      end
    EOF

    expected_refactored = <<-EOF
      module A
        class B
          Z.new
        end

        class J
          C.new
        end
      end
    EOF

    actual_refactored = refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "substitutes according to the inline namespace that was present" do
    renamer = Reruby::RenameConst::Rewriter.new(from:"A::B", to:"Z")

    code = <<-EOF
      A::B.new
    EOF

    expected_refactored = <<-EOF
      A::Z.new
    EOF

    actual_refactored = refactor(code, renamer)


    expect(actual_refactored).to eql(expected_refactored)

  end

  it "renames class definitions" do
    renamer = Reruby::RenameConst::Rewriter.new(from:"A::B", to:"Z")

    code = <<-EOF
      module A
        class B
        end
      end
    EOF

    expected_refactored = <<-EOF
      module A
        class Z
        end
      end
    EOF

    actual_refactored = refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "does all of them at the same time" do
    renamer = Reruby::RenameConst::Rewriter.new(from:"A::B", to:"Z")

    code = <<-EOF
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
    EOF

    expected_refactored = <<-EOF
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
    EOF

    actual_refactored = refactor(code, renamer)

    expect(actual_refactored).to eql(expected_refactored)
  end

end