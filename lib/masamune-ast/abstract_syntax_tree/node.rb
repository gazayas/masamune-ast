# TODO: Not sure if I'll implement this yet.

module MasamuneAst
  class AbstractSyntaxTree
    class Node
      def initialize(tree_node)
        @contents = tree_node
      end

      # i.e. - [:@ident, "variable_name", [4, 7]]
      def is_data_node?
        @contents[0].is_a?(Symbol) && @contents[1].is_a?(String) && (@contents[2][0].is_a?(Integer) && @contents[2][1].is_a?(Integer))
      end
    end
  end
end
