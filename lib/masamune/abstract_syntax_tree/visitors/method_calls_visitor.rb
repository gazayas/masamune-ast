module Masamune
  class AbstractSyntaxTree
    class MethodCallsVisitor < Prism::Visitor
      attr_reader :token_value, :results

      def initialize(token_value)
        @token_value = token_value
        @results = []
      end

      def visit_call_node(node)
        # TODO: We should probably replace this with unless node.variable_call?
        if node.method_call?
          results << node if token_value.nil? || token_value == node.name.to_s
        end
        super
      end
    end
  end
end
