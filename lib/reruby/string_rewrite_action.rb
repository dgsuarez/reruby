module Reruby
  class StringRewriteAction < RewriteAction

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
