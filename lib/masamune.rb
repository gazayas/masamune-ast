# frozen_string_literal: true

require_relative "masamune/version"
require "ripper"
require "active_support/core_ext/string/inflections"
require "masamune/lex_node"
require "masamune/slasher"
require "masamune/abstract_syntax_tree"
require "masamune/abstract_syntax_tree/node"
require "masamune/abstract_syntax_tree/data_node"

require "masamune/abstract_syntax_tree/nodes/support_nodes/block"
require "masamune/abstract_syntax_tree/nodes/support_nodes/comment"

require "masamune/abstract_syntax_tree/nodes/blocks/brace_block"
require "masamune/abstract_syntax_tree/nodes/blocks/do_block"
require "masamune/abstract_syntax_tree/nodes/symbols/dyna_symbol"
require "masamune/abstract_syntax_tree/nodes/symbols/symbol_literal"
require "masamune/abstract_syntax_tree/nodes/variables/block_var"
require "masamune/abstract_syntax_tree/nodes/variables/var_field"
require "masamune/abstract_syntax_tree/nodes/variables/var_ref"
require "masamune/abstract_syntax_tree/nodes/assign"
require "masamune/abstract_syntax_tree/nodes/call"
require "masamune/abstract_syntax_tree/nodes/command"
require "masamune/abstract_syntax_tree/nodes/def"
require "masamune/abstract_syntax_tree/nodes/params"
require "masamune/abstract_syntax_tree/nodes/program"
require "masamune/abstract_syntax_tree/nodes/string_content"
require "masamune/abstract_syntax_tree/nodes/symbol"
require "masamune/abstract_syntax_tree/nodes/vcall"

require "pp"

module Masamune
end
