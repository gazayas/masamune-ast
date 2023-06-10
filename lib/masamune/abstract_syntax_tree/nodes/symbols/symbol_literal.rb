# TODO: Add description.

module Masamune
  class AbstractSyntaxTree
    class SymbolLiteral < Node
      def initialize(contents, ast_id)
        super
      end

      # Symbol Literals are a node type of :symbol_literal,
      # but have a node type of :symbol nested within them.
      # For the reason, the data node is technically for :symbol
      # and not :symbol_literal, so instead of duplicating it here,
      # we just use a method specifically for getting the symbol.
      # This should be the same as the :dyna_symbol type.
      def get_symbol_data
        DataNode.new(@contents[1][1], @ast_id, self)
      end
    end
  end
end
