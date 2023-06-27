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
        final_result = []

        line_numbers = results.map {|result| result[:line_number]}.uniq.sort
        line_numbers.each do |line_number|
          # Group data together in an array if they're on the same line.
          shared_line_data = results.select {|result| result[:line_number] == line_number}

          # Sort the positions on each line number respectively.
          indexes_on_line = shared_line_data.map {|data| data[:index_on_line]}.sort

          # Apply to the final result.
          indexes_on_line.each do |index_on_line|
            shared_line_data.each do |data|
              if data[:index_on_line] == index_on_line
                final_result << data
              end
            end
          end
        end

        final_result
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
