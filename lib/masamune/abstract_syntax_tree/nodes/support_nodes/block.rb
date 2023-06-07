# DoBlock and BraceBlock share some of
# the same logic, so we share that here.

module Masamune
  class AbstractSyntaxTree
    class Block < Node
      def initialize(contents, ast_id)
        super
      end

      def params
        # This node should exist already, so we search for it in the ast object.
        block_var = BlockVar.new(contents[1], ast_id)
        ast.node_list.find {|node| node.contents == block_var.contents}
      end
    end
  end
end
