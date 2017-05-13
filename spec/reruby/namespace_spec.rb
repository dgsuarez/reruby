require 'spec_helper'

describe Reruby::Namespace do

  describe "#can_resolve_to?" do

    it "resolves when 2 namespaces are equal" do
      usage_namespace = namespace(%w(J::A))
      definition_namespace = namespace(%w(J A))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_truthy
    end

    it "resolves for equal namespaces no matter the relative/absolute definition" do
      namespace1 = namespace(%w(A::B C))
      namespace2 = namespace(%w(A B C))

      expect(namespace1.can_resolve_to?(namespace2)).to be_truthy
    end

    it "resolves by jumping consts in the middle of relative namespaces" do
      usage_namespace = namespace(%w(A B C))
      definition_namespace = namespace(%w(A C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_truthy
    end

    it "doesn't resolve because you can't jump consts in absolute namespaces" do
      usage_namespace = namespace(%w(A::B::W::C))
      definition_namespace = namespace(%w(A B C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "doesn't resolve a more general path to a more specific one" do
      usage_namespace = namespace(%w(A C))
      definition_namespace = namespace(%w(A B C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "resolves roots inside any relative namespace" do
      usage_namespace = namespace(%w(A B C))
      definition_namespace = namespace(%w(C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_truthy
    end

    it "doesn't resolve if the definition is root and it's used on an absolute namespace" do
      usage_namespace = namespace(%w(J::A))
      definition_namespace = namespace(%w(A))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "doesn't resolve when parts of the usage namespace don't match the definition one" do
      usage_namespace = namespace(%w(A J C))
      definition_namespace = namespace(%w(A B C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "doesn't resolve when the last const is not the same" do
      usage_namespace = namespace(%w(A J C))
      definition_namespace = namespace(%w(A J D))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "doesn't resolve if the last absolute path is not exactly equal" do
      usage_namespace = namespace(%w(A B J::C))
      definition_namespace = namespace(%w(A B J D C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy

    end

    it "resolves with absolute namespaces in the middle" do
      usage_namespace = namespace(["Reruby", "RenameConst::Rewriter", "Scope"])
      definition_namespace = namespace(["Reruby", "Scope"])

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_truthy
    end

    it "properly resolves when the usage namespace is root and a non-root could match otherwise" do
      usage_namespace = Reruby::Namespace::Root.new("A")
      definition_namespace = namespace(["A", "A"])

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "doesn't resolve when the namespace is not properly ordered" do
      usage_namespace = namespace(["A", "B", "C"])
      definition_namespace = namespace(["B", "A", "C"])

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "doesn't resolve when the definition is less specific than the usage" do
      usage_namespace = namespace(["A"])
      definition_namespace = namespace(["A", "A"])

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "resolves fine repeated namespaces" do
      usage_namespace = namespace(["A", "A", "A"])
      definition_namespace = namespace(["A", "A", "A"])

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_truthy
    end


  end

  describe "#nesting_level_in" do
    it "returns nil when they aren't nested" do
      one_ns = namespace(%w(Z::A))
      other_ns = namespace(%w(J::A))

      nesting_level = one_ns.nesting_level_in(other_ns)

      expect(nesting_level).to be_nil
    end

    it "returns the number of different consts" do
      one_ns = namespace(%w(Z::A))
      other_ns = namespace(%w(Z::A::B::C))

      nesting_level = other_ns.nesting_level_in(one_ns)

      expect(nesting_level).to eq 2

    end
  end

  describe "#relative_path" do
    it "returns the module as a unix path" do
      one_ns = namespace(%w(Some::ClassName))

      expected = "some/class_name.rb"

      expect(one_ns.relative_path).to eq(expected)
    end

  end

end
