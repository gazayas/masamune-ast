# TODO: Not sure if I'll implement this yet.

module MasamuneAst
  class AbstractSyntaxTree
    class DataNode << MasamuneAst::AbstractSyntaxTree::Node
      def initialize(tree_node)
        @parent, @contents, _ = tree_node
      end
    end
  end
end
