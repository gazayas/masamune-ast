# In the abstract syntax tree created by Ripper.sexp,
# the type for comments is :void_stmt, and it doesn't have
# a data node within it either. This means that the text
# for the comment doesn't exist in the ast. It DOES exist
# in LexNode though, so we grab from them there instead.

module Masamune
  class AbstractSyntaxTree
    class Comment < Node
      def initialize(contents, ast_id)
        # Since this is techincally supposed to be a :void_stmt
        # in this ast, we just leave this as nil.
        @contents = nil
        super
      end

      def extract_data_nodes
        [
          DataNode.new([contents.type, contents.token, contents.position], @ast_id)
        ]
      end
    end
  end
end
