# Program represents the top layer of the AST,
# and the second element of the array houses the entire program.

module Masamune
  class AbstractSyntaxTree
    class Program < Node
      def initialize(contents, ast_id)
        super
      end

      def extract_data_nodes
        # No data notes to extract.
      end
    end
  end
end
