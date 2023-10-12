module Masamune
  class AbstractSyntaxTree
    class ParametersVisitor < Prism::Visitor
      attr_reader :results

      def initialize
        @results = []
      end

      # Since parameters nodes can house multiple variables in one node,
      # we don't have to check for a token_value.
      def visit_parameters_node(node)
        results << node
        super
      end
    end
  end
end
