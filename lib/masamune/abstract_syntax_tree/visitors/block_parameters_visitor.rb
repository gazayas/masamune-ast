module Masamune
  class AbstractSyntaxTree
    class BlockParametersVisitors < Prism::Visitor
      attr_reader :results

      def initialize
        @results = []
      end

      # Since block parameters nodes can house multiple variables in one node,
      # we don't have to check for a token_value.
      def visit_block_parameters_node(node)
        results << node
        super
      end
    end
  end
end
