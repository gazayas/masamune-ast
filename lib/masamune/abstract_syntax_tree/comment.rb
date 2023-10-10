# TODO: This has only been tested with one-line comments.

module Masamune
  class AbstractSyntaxTree
    class Comment < Prism::Comment
      attr_reader :ast_id

      def initialize(comment_type, comment_location, ast_id)
        @ast_id = ast_id
        super(comment_type, comment_location)
      end

      # We grab the comment from the original Prism object's source because
      # Prism::Comment doesn't have a method that shows the string itself.
      def token
        ast = ObjectSpace._id2ref(@ast_id)
        ast.prism.source.source[self.location.start_offset..self.location.end_offset]
      end
    end
  end
end
