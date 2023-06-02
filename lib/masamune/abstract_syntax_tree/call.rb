# TODO: Add description.

module Masamune
  class AbstractSyntaxTree
    class Call < Node
      def initialize(contents, ast_id)
        super
      end

      def extract_data_nodes
        [
          Masamune::AbstractSyntaxTree::DataNode.new(@contents.last, @ast_id)
        ]
      end
    end
  end
end
