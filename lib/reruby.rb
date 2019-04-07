require 'parser/current'
require 'active_support/inflector'
require 'active_support/core_ext/module/delegation'

require 'logger'
require 'singleton'
require 'yaml'
require 'json'
require 'fileutils'
require 'shellwords'
require 'open3'
require 'pathname'
require 'English'

require 'reruby/version'
require 'reruby/config'
require 'reruby/config_parser'
require 'reruby/rubocop_autofix'
require 'reruby/log'
require 'reruby/namespace'
require 'reruby/text_range'
require 'reruby/parser_wrappers/require'
require 'reruby/parser_wrappers/const_group'
require 'reruby/parser_wrappers/namespace_with_node'
require 'reruby/parser_wrappers/code_region'
require 'reruby/namespace_paths'
require 'reruby/namespaces_in_source'
require 'reruby/file_finder'
require 'reruby/source_locator'
require 'reruby/changed_files'
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

require 'reruby/extract_method'
require 'reruby/extract_method/undefined_variables_extractor'
require 'reruby/extract_method/extracted_method'
require 'reruby/extract_method/change_for_invocation_rewriter'
require 'reruby/extract_method/add_new_method_rewriter'

require 'reruby/git_autocommit'

module Reruby
  def self.logger
    Log.instance.logger
  end
end
