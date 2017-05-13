module Reruby

  class NamespaceTracker


    def initialize
      @parts = []
    end

    def open_namespace(inline_consts, &b)
      if inline_consts.forced_root?
        shadowing_opened_namespace(inline_consts.without_forced_root, &b)
        return
      end
      parts.push(inline_consts.as_source)
      yield
      parts.pop
    end

    def shadowing_opened_namespace
      old_namespace = parts
      @parts = []
      yield
      @parts = old_namespace
    end

    def namespace_with_added(inline_consts)
      full_namespace = parts + [inline_consts.as_source]
      Namespace.from_list(full_namespace)
    end

    def namespace
      Namespace.from_list(parts.dup)
    end

    private

    attr_reader :parts

  end
end
