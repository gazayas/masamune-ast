# A data node represents an abstraction in the AST which has details about a specific type.
# i.e. - [:@ident, "variable_name", [4, 7]]
# These values are the `type`, `token`, and `position`, respectively.
# It is simliar to what you see in `Ripper.lex(code)` and `Masamune::AbstractSyntaxTree's @lex_nodes`.

# We break this down into a simpler structure, `line_data_and_token`,
# which looks like this: {line_number: 4, index_on_line: 7, token: "ruby"}

module Masamune
  class AbstractSyntaxTree
    class DataNode < Node
      attr_reader :type, :token, :line_number, :index_on_line

      def initialize(contents, ast_id, parent)
        @type, @token, line_position = contents
        @line_number, @index_on_line = line_position
        @parent = parent
        super(contents, ast_id)
      end

      # Results here represent the position and token of the
      # data we're searching in the form of a Hash like the following:
      # [
      #   {line_number: 4, index_on_line: 7, token: "ruby"},
      #   {line_number: 7, index_on_line: 7, token: "rails"}
      # ]
      # TODO: Worry about using a faster sorting algorithm later.
      def self.order_results_by_position(results)
        results.sort do |a, b|
          by_line = a[:line_number] <=> b[:line_number]
          # If we're on the same line, refer to the inner index for order.
          by_line.zero? ? a[:index_on_line] <=> b[:index_on_line] : by_line
        end
      end

      def line_data_and_token
        {
          line_number: @line_number,
          index_on_line: @index_on_line,
          token: @token
        }
      end

      def position
        [@line_number, @index_on_line]
      end
    end
  end
end
