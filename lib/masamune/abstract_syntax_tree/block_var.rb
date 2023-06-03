# TODO: Add description.

module Masamune
  class AbstractSyntaxTree
    class BlockVar < Node
      attr_accessor :ast_id

      def initialize(contents, ast_id)
        super
      end

      # :block_var has a lot of nil values within in.
      # I'm not sure what this represents, but it would be
      # nice to find out and implement it document/implement it somewhere.
      def extract_data_nodes
        @contents[1][1].map do |content|
          DataNode.new(content, @ast_id)
        end
      end
    end
  end
end
