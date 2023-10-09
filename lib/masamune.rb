# frozen_string_literal: true

require_relative "masamune/version"
require "ripper"
require "prism"

require "active_support/core_ext/string/inflections"
require "masamune/lex_node"
require "masamune/slasher"
require "masamune/abstract_syntax_tree"
require "masamune/abstract_syntax_tree/node_helper"
require "masamune/abstract_syntax_tree/comment"

require "pp"

module Masamune
end
