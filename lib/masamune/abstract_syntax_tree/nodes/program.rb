# Program represents the top layer of the abstract syntax tree,
# and the second element of the array houses the entire program.

module Masamune
  class AbstractSyntaxTree
    class Program < Node
      def initialize(contents, ast_id)
        super
      end

      def extract_data_nodes
        # No data nodes to extract.
      end
    end
  end
end
