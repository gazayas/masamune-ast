# frozen_string_literal: true

require_relative "masamune/version"
require "ripper"
require "prism"
require "active_support/core_ext/string/inflections"

require "masamune/abstract_syntax_tree/visitors/block_parameters_visitor"
require "masamune/abstract_syntax_tree/visitors/method_definitions_visitor"
require "masamune/abstract_syntax_tree/visitors/method_calls_visitor"
require "masamune/abstract_syntax_tree/visitors/parameters_visitor"
require "masamune/abstract_syntax_tree/visitors/strings_visitor"
require "masamune/abstract_syntax_tree/visitors/symbols_visitor"
require "masamune/abstract_syntax_tree/visitors/variables_visitor"

require "masamune/lex_node"
require "masamune/slasher"
require "masamune/abstract_syntax_tree"

require "pp"

module Masamune
end
