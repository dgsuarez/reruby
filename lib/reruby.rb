require 'parser/current'
require 'active_support/inflector'

require 'logger'
require 'singleton'

require "reruby/version"
require "reruby/config"
require "reruby/log"
require 'reruby/scope'
require 'reruby/inline_consts'
require 'reruby/namespace_tracker'
require 'reruby/definitions'
require 'reruby/file_finder'
require 'reruby/actions/bulk_file_rename'
require 'reruby/actions/rewrite'
require 'reruby/actions/file_rewrite'
require 'reruby/actions/string_rewrite'
require 'reruby/scope'
require 'reruby/rename_const'
require 'reruby/rename_const/rewriter'
require 'reruby/rename_const/file_renames'

module Reruby
  def self.logger
    Log.instance.logger
  end
end
