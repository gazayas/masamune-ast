# frozen_string_literal: true

require_relative "masamune/version"
require "ripper"
require "active_support/core_ext/string/inflections"
require "masamune/lex_node"
require "masamune/slasher"
require "masamune/abstract_syntax_tree"
require "masamune/abstract_syntax_tree/node"
require "masamune/abstract_syntax_tree/data_node"

# Node Types
require "masamune/abstract_syntax_tree/assign"
require "masamune/abstract_syntax_tree/block_var"
require "masamune/abstract_syntax_tree/brace_block"
require "masamune/abstract_syntax_tree/call"
require "masamune/abstract_syntax_tree/def"
require "masamune/abstract_syntax_tree/do_block"
require "masamune/abstract_syntax_tree/dyna_symbol"
require "masamune/abstract_syntax_tree/params"
require "masamune/abstract_syntax_tree/program"
require "masamune/abstract_syntax_tree/string_content"
require "masamune/abstract_syntax_tree/symbol_literal"
require "masamune/abstract_syntax_tree/symbol"
require "masamune/abstract_syntax_tree/var_field"
require "masamune/abstract_syntax_tree/var_ref"
require "masamune/abstract_syntax_tree/vcall"

require "pp"
require "pry"

module Masamune
end
