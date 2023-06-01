# TODO: Add description.

module Masamune
  class AbstractSyntaxTree
    class DoBlock < Node
      attr_accessor :ast_id

      def initialize(contents, ast_id)
        super
      end

      def params
        # This node should exist already, so we search for it in the ast object.
        block_var = Masamune::AbstractSyntaxTree::BlockVar.new(contents[1], ast_id)
        ast.node_list.find {|node| node.contents == block_var.contents}
      end
    end
  end
end
