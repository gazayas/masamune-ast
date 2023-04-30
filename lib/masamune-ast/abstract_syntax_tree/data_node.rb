# TODO: Not sure if I'll implement this yet.

module Masamune
  class AbstractSyntaxTree
    class DataNode << Masamune::AbstractSyntaxTree::Node
      def initialize(tree_node)
        @parent, @contents, _ = tree_node
      end
    end
  end
end
