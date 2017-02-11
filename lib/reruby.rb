require 'parser/current'
require 'active_support/inflector'

require 'logger'

require "reruby/version"
require "reruby/config"
require "reruby/log"
require 'reruby/scope'
require 'reruby/rewrite_action'
require 'reruby/file_rewrite_action'
require 'reruby/file_finder'
require 'reruby/bulk_file_renamer'
require 'reruby/scope'
require 'reruby/rename_const'
require 'reruby/rename_const/rewriter'
require 'reruby/rename_const/file_renames'

module Reruby
  def self.logger
    Log.instance
  end
end
