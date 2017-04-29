require 'parser/current'
require 'active_support/inflector'

require 'logger'
require 'singleton'

require "reruby/version"
require "reruby/config"
require "reruby/log"
require 'reruby/namespace'
require 'reruby/inline_consts'
require 'reruby/namespace_tracker'
require 'reruby/namespace_paths'
require 'reruby/defined_consts'
require 'reruby/file_finder'
require 'reruby/source_locator'
require 'reruby/actions/bulk_file_operations'
require 'reruby/actions/rewrite'
require 'reruby/actions/file_rewrite'
require 'reruby/actions/string_rewrite'

require 'reruby/rename_const'
require 'reruby/rename_const/rewriter'
require 'reruby/rename_const/file_renames'

require 'reruby/explode_namespace'
require 'reruby/explode_namespace/children_namespace_files'
require 'reruby/explode_namespace/main_file_rewriter'

require 'reruby/instance_to_reader'
require 'reruby/instance_to_reader/rewriter'

module Reruby
  def self.logger
    Log.instance.logger
  end
end
