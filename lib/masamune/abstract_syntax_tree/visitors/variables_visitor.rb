module Masamune
  class AbstractSyntaxTree
    class VariablesVisitor < Prism::Visitor
      attr_reader :token_value, :results

      def initialize(token_value)
        @token_value = token_value
        @results = []
      end

      def visit_local_variable_write_node(node)
        results << node if token_value.nil? || token_value == node.name.to_s
        super
      end

      def visit_local_variable_read_node(node)
        results << node if token_value.nil? || token_value == node.name.to_s
        super
      end

      def visit_required_parameter_node(node)
        results << node if token_value.nil? || token_value == node.name.to_s
        super
      end

      def visit_call_node(node)
        if node.variable_call?
          results << node if token_value.nil? || token_value == node.name
        end
        super
      end
    end
  end
end
