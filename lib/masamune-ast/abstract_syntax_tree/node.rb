# TODO: Add description

module Masamune
  class AbstractSyntaxTree
    class Node
      attr_reader :ast_id, :contents, :index_stack, :data_nodes

      def initialize(contents, ast_id)
        @ast_id = ast_id
        @contents = contents
        @data_nodes = extract_data_nodes
      end

      def ast
        ObjectSpace._id2ref(@ast_id)
      end

      # TODO: Consider removing the :type and :typeless methods.

      # Ripper's abstract syntax tree nodes are either typed or typeless.
      # Types consist of values such as :def, :do_block, :var_ref, etc.
      # Typed nodes house one of these types as its first element,
      # whereas typeless nodes simply have arrays as top-level elements.
      # Example of a typed node: [:@tstring_content, "ruby", [4, 7]]
      def typed?
        @contents.is_a?(Array) && @contents.first.is_a?(Symbol)
      end

      def typeless?
        !typed?
      end

      # By default, we assume a node has no data nodes to extract.
      # Because the structure for each node is different, we handle
      # extraction separately for each node within its respective class.
      def extract_data_nodes
        # TODO: Might want to make this [] instead of nil.
      end
    end
  end
end
