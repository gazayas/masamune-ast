module Masamune
  class AbstractSyntaxTree
    class StringsVisitor < Prism::Visitor
      attr_reader :token_value, :results

      def initialize(token_value)
        @token_value = token_value
        @results = []
      end

      def visit_string_node(node)
        results << node unless token_value.present? && token_value != node.content
        super
      end
    end
  end
end
