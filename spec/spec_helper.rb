$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'reruby'

require 'byebug'
require 'active_support/core_ext/string/strip'

def namespace(consts)
  Reruby::Namespace.from_list(consts)
end

def inline_refactor(code, refactoring_action)
  rewriter = Reruby::Actions::StringRewrite.new(code, refactoring_action)
  rewriter.perform
end
