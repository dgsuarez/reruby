require 'spec_helper'

describe Reruby::Scope do

  def scope(consts)
    Reruby::Scope.new(consts)
  end

  it "knows that you can add arbitrary consts at the end of the external namespace" do
    usage_scope = scope(%w(A B C))
    definition_scope = scope(%w(A C))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_truthy
  end

  it "knows that for full scopes it doesn't matter the external/inline definition" do
    scope1 = scope(%w(A B C))
    scope2 = scope(%w(A B::C))

    expect(scope1.can_resolve_to?(scope2)).to be_truthy
  end

  it "knows that you can't add arbitrary consts in the middle of the inline namespace" do
    usage_scope = scope(%w(A::B::W::C))
    definition_scope = scope(%w(A B C))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_falsy
  end

  it "knows that a more general path can't resolve to a more specific one" do
    usage_scope = scope(%w(A C))
    definition_scope = scope(%w(A B C))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_falsy
  end

  it "knows that you can always resolve root consts inside any namespace" do
    usage_scope = scope(%w(A B C))
    definition_scope = scope(%w(C))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_truthy
  end

  it "doesn't resolve if the definition is root but on a inline ns " do
    usage_scope = scope(%w(J::A))
    definition_scope = scope(%w(A))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_falsy
  end

  it "doesn't resolve when all the consts in the definiton aren't there" do
    usage_scope = scope(%w(A J C))
    definition_scope = scope(%w(A B C))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_falsy
  end

  it "knows that 2 scopes are equal so they resolve" do
    usage_scope = scope(%w(J::A))
    definition_scope = scope(%w(J::A))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_truthy

  end


end
