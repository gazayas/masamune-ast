require "masamune/abstract_syntax_tree"
require "masamune/slicer"

module Masamune
  class Base
    include Slicer

    attr_reader :code, :lex_nodes, :ast

    def initialize(code)
      raise ArgumentError, "You must pass a String as an argument" unless code.is_a?(String)
      @code = code
      @ast = AbstractSyntaxTree.new(@code)
      raw_lex_nodes = Ripper.lex(@code)
      @lex_nodes = raw_lex_nodes.map{ |data| LexNode.new(raw_lex_nodes.index(data), data, ast.__id__) }
    end
  end
end
