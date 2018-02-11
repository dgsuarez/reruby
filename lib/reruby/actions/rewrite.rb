module Reruby
  module Actions
    class Rewrite

      def changed?
        changed
      end

      protected

      attr_reader :changed

      def rewrite(code)
        buffer = Parser::Source::Buffer.new('')
        parser = Parser::CurrentRuby.new
        buffer.source = code
        ast = parser.parse(buffer)
        new_code = rewriter.rewrite(buffer, ast)

        @changed = code != new_code

        new_code
      end
    end
  end
end
