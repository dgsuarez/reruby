require_relative '../spec_helper'

describe Reruby::RenameClass do

  it "renames the given constant in the given code" do
    renamer = Reruby::RenameClass.new(from:"A", to:"Z")

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

    actual_refactored = renamer.perform(code)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "ignores code from other namespaces" do
    renamer = Reruby::RenameClass.new(from:"A", to:"Z")

    code = <<-EOF
      c = J::A.done!
    EOF

    expected_refactored = <<-EOF
      c = J::A.done!
    EOF

    actual_refactored = renamer.perform(code)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "is aware of the full module where the class is defined" do
    renamer = Reruby::RenameClass.new(from:"A::B", to:"A::Z")

    code = <<-EOF
      module A
        B.new
      end
    EOF

    expected_refactored = <<-EOF
      module A
        Z.new
      end
    EOF

    actual_refactored = renamer.perform(code)

    expect(actual_refactored).to eql(expected_refactored)
  end

end
