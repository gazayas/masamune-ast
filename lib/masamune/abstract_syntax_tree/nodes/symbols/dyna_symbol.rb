# TODO: Add description.

module Masamune
  class AbstractSyntaxTree
    class DynaSymbol < Node
      def initialize(contents, ast_id)
        super
      end

      # Dyna Symbols are symbols created from strings, i.e. - :"project".
      # Since they have :@tstring_content inside of them, the data node
      # is technically for a String, so instead of duplicating it here,
      # we just use a method specifically for getting the symbol.
      # This should be the same as the :symbol_literal type.
      def get_symbol_data
        DataNode.new(@contents[1][1], @ast_id, self)
      end
    end
  end
end
