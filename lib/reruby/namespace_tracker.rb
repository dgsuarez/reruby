module Reruby

  class NamespaceTracker

    attr_reader :namespace

    def initialize
      @namespace = []
    end

    def open_namespace(inline_consts, &b)
      if inline_consts.forced_root?
        shadowing_opened_namespace(inline_consts.without_forced_root, &b)
        return
      end
      namespace.push(inline_consts.as_source)
      yield
      namespace.pop
    end

    def shadowing_opened_namespace
      old_namespace = namespace
      @namespace = []
      yield
      @namespace = old_namespace
    end

    def scope_with_added(inline_consts)
      full_namespace = namespace + [inline_consts.as_source]
      Scope.new(full_namespace)
    end

  end
end
