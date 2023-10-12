module Masamune
  class AbstractSyntaxTree
    class VariablesVisitor < Prism::Visitor
      attr_reader :token_value, :results

      def initialize(token_value)
        @token_value = token_value
        @results = []
      end

      def visit_local_variable_write_node(node)
        results << node unless token_value.present? && token_value != node.name.to_s
        super
      end

      def visit_local_variable_read_node(node)
        results << node unless token_value.present? && token_value != node.name.to_s
        super
      end

      def visit_required_parameter_node(node)
        results << node unless token_value.present? && token_value != node.name.to_s
        super
      end
    end
  end
end
