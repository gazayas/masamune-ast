# TODO: This has only been tested with one-line comments.

module Masamune
  class AbstractSyntaxTree
    class Comment < Prism::Comment
      attr_reader :ast_id

      include NodeHelper

      def initialize(comment_type, comment_location, ast_id)
        @ast_id = ast_id
        super(comment_type, comment_location)
      end

      # TODO: Potentially just grab this from the proper Lex node.
      # Prism.parse(code).value.slice does not contain any comments that are placed at the end.
      # Also, there is no helper method to grab comment tokens in Prism.
      def token
        ast = ObjectSpace._id2ref(@ast_id)
        ast.code[self.location.start_offset..self.location.end_offset]
      end
    end
  end
end
