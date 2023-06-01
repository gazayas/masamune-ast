# A data node represents an abstraction in the AST which has details about a specific type.
# i.e. - [:@ident, "variable_name", [4, 7]]
# These values are the `type`, `token`, and `position`, respectively.
# It is simliar to what you see in `Ripper.lex(code)` and `Masamune::AbstractSyntaxTree's @lex_nodes`.

module Masamune
  class AbstractSyntaxTree
    class DataNode < Node
      attr_reader :type, :token, :line_position

      def initialize(contents, ast_id)
        @type, @token, @line_position = contents
        super(contents, ast_id)
      end

      def position_and_token
        [@line_position, @token]
      end

      # TODO: Write this method.
      # Results here represent the data we get when searching for data.
      # For example, [[[4, 7], "ruby"], [[7, 7], "rails"]].
      def self.order_results_by_position(position_and_token_ary)
        position_and_token_ary
      end
    end
  end
end
