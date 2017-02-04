module Reruby

  class FileRewriteAction < SourceRewriteAction

    attr_reader :path, :rewriter

    def initialize(path: nil, rewriter: nil)
      @path = path
      @rewriter = rewriter
    end

    def perform
      old_code = File.read(path)
      new_code = rewrite(code)

      File.write(path, new_code) if old_code != new_code
    end

  end

end
