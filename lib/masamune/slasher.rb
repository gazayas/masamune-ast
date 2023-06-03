module Masamune
  module Slasher
    def self.replace(type:, old_token:, new_token:, code:, ast:)
      # `type` can either be a method from the ast like `method_definitions`,
      # or it can be a list of Masamune::AbstractSyntaxTree node classes.
      position_and_token_ary = if type.is_a?(Symbol) && ast.respond_to?(type)
        ast.send(type)
      elsif type.is_a?(Array)
        type.map {|klass| ast.find_nodes(klass)}.flatten
      end

      tokens_to_replace = position_and_token_ary.select do |pos_and_tok|
        pos_and_tok[:token] == old_token
      end

      # Build from lex nodes
      result = ast.lex_nodes.map do |lex_node|
        match_found = false
        tokens_to_replace.each do |position_and_token|
          if position_and_token[:position] == lex_node.position
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
