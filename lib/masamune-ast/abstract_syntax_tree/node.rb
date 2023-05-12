module Masamune
  class AbstractSyntaxTree
    class Node
      attr_reader :ast_id, :contents, :type, :parent

      def initialize(contents, ast_id, parent = nil)
        @contents = contents
        @ast_id = ast_id
        @parent = parent
        @type = @contents.first if typed?

        @data_nodes = []
        @data_nodes = extract_data_nodes if has_data_node?
      end

      def ast
        ObjectSpace._id2ref(@ast_id)
      end

      # Ripper's abstract syntax tree nodes are either typed or typeless.
      # Types consist of values such as :def, :do_block, :var_ref, etc.
      # Typed nodes house one of these types as its first element,
      # whereas typeless nodes simply have arrays as top-level elements.
      # Example of a typed node: [:@tstring_content, "ruby", [4, 7]]
      def typed?
        @contents.first.is_a?(Symbol)
      end

      def typeless?
        !typed?
      end

      # The structure for each type is already determined in Ripper, so we can be
      # certain that a data node exists within a node simply by knowing the type.
      def has_data_node?
        [
          :def,
          :call,
          :var_field,
          :var_ref,
          :vcall,
          :string_content
        ].include?(@type)
      end

      # Since each typed node has a specific structure, we have
      # to handle each one individually to extract the data nodes.
      #
      # Most data nodes live at the second index of the array:
      # i.e. - [:var_ref, [:@ident, "java", [3, 2]]]
      def extract_data_nodes
        return if typeless?

        case
        when :def
        when :call
        else
          @contents[1]
        end
      end

      # TODO: Eventually would like to use this for the explorer.
      def index_in_tree
      end
    end
  end
end
