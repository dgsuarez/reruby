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

    it "doesn't resolve when a parent is referenced inside" do
      usage_namespace = namespace(["A", "B", "A"])
      definition_namespace = namespace(["A", "B"])

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end


  end

  describe "#nested_one_level_in?" do
    it "returns truthy when nested exactly one level deep in given namespace " do
      one_ns = namespace(%w(Z::A::B))
      given_ns = namespace(%w(Z::A))

      nested_one_level = one_ns.nested_one_level_in?(given_ns)

      expect(nested_one_level).to be_truthy
    end

    it "returns falsey when not nested in given namespace" do
      one_ns = namespace(%w(Z::A))
      given_ns = namespace(%w(J::A))

      nested_one_level = one_ns.nested_one_level_in?(given_ns)

      expect(nested_one_level).to be_falsey
    end

    it "returns falsey when nested more than one level deep in given namespace " do
      one_ns = namespace(%w(Z::A::B::C))
      given_ns = namespace(%w(Z::A))

      nested_one_level = one_ns.nested_one_level_in?(given_ns)

      expect(nested_one_level).to be_falsey
    end
  end

  describe "#nested_in_or_same_as?" do
    it "returns truthy when nested exactly one level deep in given namespace " do
      one_ns = namespace(%w(Z::A::B))
      given_ns = namespace(%w(Z::A))

      result = one_ns.nested_in_or_same_as?(given_ns)

      expect(result).to be_truthy
    end

    it "returns falsey when not nested in given namespace" do
      one_ns = namespace(%w(Z::A))
      given_ns = namespace(%w(J::A))

      nested_one_level = one_ns.nested_in_or_same_as?(given_ns)

      expect(nested_one_level).to be_falsey
    end

    it "returns truthy when given namespace is the same" do
      one_ns = namespace(%w(Z::A))
      given_ns = namespace(%w(Z::A))

      nested_one_level = one_ns.nested_in_or_same_as?(given_ns)

      expect(nested_one_level).to be_truthy
    end
  end

  describe ".from_require" do
    it "returns the expected namespace to be defined in a given require path" do
      require_path = "foo/bar/baz"
      expected_namespace = Reruby::Namespace.from_source("Foo::Bar::Baz")

      result = Reruby::Namespace.from_require_path(require_path)

      expect(result).to eq(expected_namespace)
    end
  end

  describe "others" do
    it "can turn itself into a unix path" do
      one_ns = namespace(%w(Some::ClassName))

      expected = "some/class_name.rb"

      expect(one_ns.relative_path).to eq(expected)
    end

    it "can turn itself into a require-style path" do
      one_ns = namespace(%w(Some::ClassName))

      expected = "some/class_name"

      expect(one_ns.as_require).to eq(expected)
    end

    it "can return its parent namespace" do
      child_ns = namespace(%w(Some::ClassName::Things))

      expected = namespace(%w(Some::ClassName))

      expect(child_ns.parent).to eq(expected)

    end

  end

end
