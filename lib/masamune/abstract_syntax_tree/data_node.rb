# A data node represents an abstraction in the AST which has details about a specific type.
# i.e. - [:@ident, "variable_name", [4, 7]]
# These values are the `type`, `token`, and `position`, respectively.
# It is simliar to what you see in `Ripper.lex(code)` and `Masamune::AbstractSyntaxTree's @lex_nodes`.

# We break this down into a simpler structure, `position_and_token`,
# which looks like this: {position: [4, 7], token: "ruby"}

module Masamune
  class AbstractSyntaxTree
    class DataNode < Node
      attr_reader :type, :token, :line_position

      def initialize(contents, ast_id, parent)
        @type, @token, @line_position = contents
        @parent = parent
        super(contents, ast_id)
      end

      # Results here represent the position and token of the
      # data we're searching in the form of a Hash like the following:
      # [
      #   {position: [4, 7], token: "ruby"},
      #   {position: [7, 7], token: "rails"}
      # ]
      # TODO: Worry about using a faster sorting algorithm later.
      def self.order_results_by_position(position_and_token_ary)
        # Extract the line numbers first, i.e - 4 from [4, 7]
        line_numbers = position_and_token_ary.map do |position_and_token|
          position_and_token[:position].first
        end.uniq.sort

        final_result = []
        line_numbers.each do |line_number|
          # Group data together in an array if they're on the same line.
          shared_line_data = position_and_token_ary.select do |position_and_token|
            position_and_token[:position].first == line_number
          end

          # Sort the positions on each line number respectively.
          positions_on_line = shared_line_data.map do |position_and_token|
            position_and_token[:position].last
          end.sort

          # Apply to the final result.
          positions_on_line.each do |position_on_line|
            shared_line_data.each do |position_and_token|
              if position_and_token[:position].last == position_on_line
                final_result << position_and_token
              end
            end
          end
        end

        final_result
      end

      def position_and_token
        {position: @line_position, token: @token}
      end
    end
  end
end
