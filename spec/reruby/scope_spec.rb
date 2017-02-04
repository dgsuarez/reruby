require 'spec_helper'

describe Reruby::Scope do

  def scope(external_namespace, inline_namespace)
    Reruby::Scope.new(external_namespace, inline_namespace)
  end

  it "knows that you can add arbitrary consts at the end of the external namespace" do
    usage_scope = scope(%w(A B W), %w(C))
    definition_scope = scope(%w(A), %w(C))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_truthy
  end

  it "knows that for full scopes it doesn't matter the external/inline definition" do
    scope1 = scope(%w(A B), %w(C))
    scope2 = scope(%w(A), %w(B C))

    expect(scope1.can_resolve_to?(scope2)).to be_truthy
  end

  it "knows that you can't add arbitrary consts in the middle of the inline namespace" do
    usage_scope = scope(%w(), %w(A B W C))
    definition_scope = scope(%w(A B), %w(C))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_falsy
  end

  it "knows that a more general path can't resolve to a more specific one" do
    usage_scope = scope(%w(A), %w(C))
    definition_scope = scope(%w(A B), %w(C))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_falsy
  end

  it "knows that you can always resolve root consts inside any namespace" do
    usage_scope = scope(%w(A B), %w(C))
    definition_scope = scope(%w(), %w(C))

    expect(usage_scope.can_resolve_to?(definition_scope)).to be_truthy
  end


end
