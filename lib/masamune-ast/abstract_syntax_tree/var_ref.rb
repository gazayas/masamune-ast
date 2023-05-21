module Masamune
  class AbstractSyntaxTree
    class VarRef < Node
      def initialize(contents, ast_id)
        super
      end

      def extract_data_nodes
        [@contents[1]]
      end
    end
  end
end
