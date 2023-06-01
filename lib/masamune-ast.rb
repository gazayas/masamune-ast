# frozen_string_literal: true

require_relative "masamune-ast/version"
require "ripper"
require "active_support/core_ext/string/inflections"
require "masamune-ast/lex_node"
require "masamune-ast/abstract_syntax_tree"
require "masamune-ast/abstract_syntax_tree/node"
require "masamune-ast/abstract_syntax_tree/data_node"

# Node Types
require "masamune-ast/abstract_syntax_tree/assign"
require "masamune-ast/abstract_syntax_tree/block_var"
require "masamune-ast/abstract_syntax_tree/brace_block"
require "masamune-ast/abstract_syntax_tree/call"
require "masamune-ast/abstract_syntax_tree/def"
require "masamune-ast/abstract_syntax_tree/do_block"
require "masamune-ast/abstract_syntax_tree/params"
require "masamune-ast/abstract_syntax_tree/program"
require "masamune-ast/abstract_syntax_tree/string_content"
require "masamune-ast/abstract_syntax_tree/var_field"
require "masamune-ast/abstract_syntax_tree/var_ref"
require "masamune-ast/abstract_syntax_tree/vcall"

require "pp"
require "pry"

module Masamune
end
