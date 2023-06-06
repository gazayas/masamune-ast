# TODO: Add description.

module Masamune
  class AbstractSyntaxTree
    class Params < Node
      def initialize(contents, ast_id)
        super
      end

      def extract_data_nodes
        # TODO: Sometimes the params node looks like this:
        # [:params, nil, nil, nil, nil, nil, nil, nil]
        # Add a description for this, and review this portion
        # to ensure that it's being handled properly.
        unless @contents[1].nil?
          @contents[1].map do |content|
            DataNode.new(content, @ast_id)
          end
        end
      end
    end
  end
end
