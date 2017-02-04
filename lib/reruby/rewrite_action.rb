module Reruby
  class RewriteAction

    protected

    def rewrite(code)
      buffer = Parser::Source::Buffer.new('')
      parser = Parser::CurrentRuby.new
      buffer.source = code
      ast = parser.parse(buffer)
      rewriter.rewrite(buffer, ast)
    end
  end
end
