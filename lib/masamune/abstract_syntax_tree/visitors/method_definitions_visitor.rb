module Masamune
  class AbstractSyntaxTree
    class MethodDefinitionsVisitor < Prism::Visitor
      attr_reader :token_value, :results

      def initialize(token_value)
        @token_value = token_value
        @results = []
      end

      def visit_def_node(node)
        results << node if token_value.nil? || token_value == node.name.to_s
        super
      end
    end
  end
end
