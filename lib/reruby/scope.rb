module Reruby
  class Scope

    def initialize(external_namespace, inline_namespace)
      @external_namespace = external_namespace
      @inline_namespace = inline_namespace
    end

    def can_resolve_to?(other_scope)
      external_is_ancestor_of?(other_scope) &&
        inline_is_exact_match_of?(other_scope)
    end

    def namespace
      external_namespace + inline_namespace
    end

    def namespace_without_last
      namespace.slice(0 .. -2)
    end

    protected

    attr_reader :external_namespace, :inline_namespace

    def external_is_ancestor_of?(other_scope)
      other_scope.namespace_without_last.zip(namespace_without_last).all? do |other_const, my_const|
        other_const == my_const
      end
    end

    def inline_is_exact_match_of?(other_scope)
      other_full = other_scope.namespace.join("::")
      my_inline = inline_namespace.join("::")

      other_full.end_with?(my_inline)
    end

  end
end
