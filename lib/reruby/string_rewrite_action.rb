module Reruby
  class StringRewriter < RewriteAction

    attr_reader :code, :rewriter

    def initialize(code, rewriter)
      @code = code
      @rewriter = rewriter
    end

    def perform
      rewrite(code)
    end

  end
end
