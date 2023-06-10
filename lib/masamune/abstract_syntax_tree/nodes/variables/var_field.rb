# TODO: Add description.

module Masamune
  class AbstractSyntaxTree
    class VarField < Node
      def initialize(contents, ast_id)
        super
      end

      def extract_data_nodes
        [
          DataNode.new(@contents[1], @ast_id, self)
        ]
      end
    end
  end
end
