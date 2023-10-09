module Masamune
  module Slasher
    def self.replace(type:, old_token:, new_token:, code:, ast:)
      # `type` can either be a method from the ast like `method_definitions`,
      # or it can be a list of Prism node classes.
      nodes = if type.is_a?(Symbol)
        type_to_method = type.to_s.pluralize.to_sym
        ast.send(type_to_method)
      elsif type.is_a?(Array)
        type.map {|klass| ast.find_nodes(klass)}.flatten
      end

      nodes_of_tokens_to_replace = nodes.select do |node|
        node.token == old_token
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

        match_found ? new_token : lex_node.token
      end

      result.join
    end
  end
end
