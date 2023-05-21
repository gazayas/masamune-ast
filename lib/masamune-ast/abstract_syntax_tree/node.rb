module Masamune
  class AbstractSyntaxTree
    class Node
      attr_reader :ast_id, :contents, :index_stack, :data_nodes

      # TODO: Might be beneficial to change parent to the object's id.
      # TODO: Change `data_nodes` to `top_level_data_nodes`.
      def initialize(contents, ast_id)
        @ast_id = ast_id
        @contents = contents
        @index_stack = index_stack
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

      # Most data nodes live at the second index of the array:
      # i.e. - [:var_ref, [:@ident, "java", [3, 2]]]
      # For all other nodes, we override this method
      # to extract the data nodes according to its structure.
      def extract_data_nodes
        # return if typeless? || !@contents.is_a?(Array) || @contents.first == :@ident
        # [@contents[1]]
      end
    end
  end
end
