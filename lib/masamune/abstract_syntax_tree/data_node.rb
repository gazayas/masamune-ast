# A data node represents an abstraction in the AST which has details about a specific type.
# i.e. - [:@ident, "variable_name", [4, 7]]
# These values are the `type`, `token`, and `position`, respectively.
# It is simliar to what you see in `Ripper.lex(code)` and `Masamune::AbstractSyntaxTree's @lex_nodes`.

# We break this down into a simpler structure, `position_and_token`,
# which looks like this: [[4, 7], "ruby"]
# TODO: I eventually want to change this to the following:
# [
#   {position: [4, 7], token: "ruby"},
#   {position: [1, 2], token: "rails"}
# ]

module Masamune
  class AbstractSyntaxTree
    class DataNode < Node
      attr_reader :type, :token, :line_position

      def initialize(contents, ast_id)
        @type, @token, @line_position = contents
        super(contents, ast_id)
      end

      # Results here represent the data we get when searching for data.
      # For example, [[[4, 7], "ruby"], [[7, 7], "rails"]].
      # TODO: Worry about using a faster sorting algorithm later.
      def self.order_results_by_position(position_and_token_ary)
        line_numbers = position_and_token_ary.map do |position_and_token|
          position = position_and_token.first
          line_number = position.first
          line_number
        end.uniq.sort

        final_result = []
        line_numbers.each do |line_number|
          # Group data together in an array if they're on the same line.
          shared_line_data = position_and_token_ary.select do |position_and_token|
            position = position_and_token.first
            position.first == line_number
          end

          # Sort the positions on each line number respectively.
          positions_on_line = shared_line_data.map do |data|
            data.first.last
          end.sort

          # Apply to the final result.
          positions_on_line.each do |position|
            shared_line_data.each do |data|
              final_result << data if data.first.last == position
            end
          end
        end

        final_result
      end

      def position_and_token
        [@line_position, @token]
      end
    end
  end
end
