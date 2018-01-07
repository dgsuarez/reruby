require 'parser/current'
require 'active_support/inflector'

require 'logger'
require 'singleton'

require "reruby/version"
require "reruby/config"
require "reruby/log"
require 'reruby/namespace'
require 'reruby/require_node'
require 'reruby/parser_const_group'
require 'reruby/namespace_paths'
require 'reruby/defined_consts'
require 'reruby/file_finder'
require 'reruby/source_locator'
require 'reruby/actions/bulk_file_operations'
require 'reruby/actions/rewrite'
require 'reruby/actions/file_rewrite'
require 'reruby/actions/string_rewrite'

require 'reruby/rename_const'
require 'reruby/rename_const/usage_rewriter'
require 'reruby/rename_const/require_rewriter'
require 'reruby/rename_const/file_renames'

require 'reruby/explode_namespace'
require 'reruby/explode_namespace/children_namespace_files'
require 'reruby/explode_namespace/main_file_rewriter'
require 'reruby/explode_namespace/add_requires_rewriter'

require 'reruby/instances_to_readers'
require 'reruby/instances_to_readers/rewriter'

module Reruby
  def self.logger
    Log.instance.logger
  end
end
