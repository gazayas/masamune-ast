module Masamune
  module Slasher
    def self.replace(type:, old_token_value:, new_token_value:, code:, ast:)
      # `type` refers to the singluar form of a method name from the ast like `method_definitions`.
      nodes = if type.is_a?(Symbol)
        type_to_method = type.to_s.pluralize.to_sym
        ast.send(type_to_method)
      end

      nodes_of_tokens_to_replace = nodes.select do |node|
        node.token_value == old_token_value
      end

      # Build from lex nodes
      result = ast.lex_nodes.map do |lex_node|
        match_found = false
        nodes_of_tokens_to_replace.each do |node|
          location = [node.token_location.start_line, node.token_location.start_column]
          if location == lex_node.location
            match_found = true
            break
          end
        end

        match_found ? new_token_value : lex_node.token
      end

      result.join
    end
  end
end
