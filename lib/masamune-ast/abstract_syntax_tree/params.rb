# TODO: Add description.

module Masamune
  class AbstractSyntaxTree
    class Params < Node
      def initialize(contents, ast_id)
        super
      end

      def extract_data_nodes
        @contents[1].map do |content|
          Masamune::AbstractSyntaxTree::DataNode.new(content, @ast_id)
        end
      end
    end
  end
end
