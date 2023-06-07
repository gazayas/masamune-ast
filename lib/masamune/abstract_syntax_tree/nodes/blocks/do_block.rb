# TODO: Add description.

module Masamune
  class AbstractSyntaxTree
    class DoBlock < Block
      attr_accessor :ast_id

      def initialize(contents, ast_id)
        super
      end
    end
  end
end
