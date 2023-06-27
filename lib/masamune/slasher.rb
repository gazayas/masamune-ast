module Masamune
  module Slasher
    def self.replace(type:, old_token:, new_token:, code:, ast:)
      # `type` can either be a method from the ast like `method_definitions`,
      # or it can be a list of Masamune::AbstractSyntaxTree node classes.
      line_data_and_token_ary = if type.is_a?(Symbol)
        type_to_method = type.to_s.pluralize.to_sym
        ast.send(type_to_method)
      elsif type.is_a?(Array)
        type.map {|klass| ast.find_nodes(klass)}.flatten
      end

      tokens_to_replace = line_data_and_token_ary.select do |line_data_and_token|
        line_data_and_token[:token] == old_token
      end

      # Build from lex nodes
      result = ast.lex_nodes.map do |lex_node|
        match_found = false
        tokens_to_replace.each do |line_data_and_token|
          position = [
            line_data_and_token[:line_number],
            line_data_and_token[:index_on_line]
          ]
          if position == lex_node.position
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
