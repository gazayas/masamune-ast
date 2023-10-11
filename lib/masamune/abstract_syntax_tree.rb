require_relative "abstract_syntax_tree/prism/node_extensions"

module Masamune
  class AbstractSyntaxTree
    attr_reader :code, :tree, :prism
    attr_accessor :nodes, :lex_nodes

    def initialize(code)
      @code = code
      @tree = Ripper.sexp(code)
      raw_lex_nodes = Ripper.lex(code)
      @lex_nodes = raw_lex_nodes.map do |lex_node|
        LexNode.new(raw_lex_nodes.index(lex_node), lex_node, self.__id__)
      end

      @prism = Prism.parse(code)
      @nodes = []
      register_nodes
      @nodes = order_nodes(@nodes)
    end

    def register_nodes(tree_node = @prism.value)
      @nodes << tree_node
      tree_node.compact_child_nodes.each do |child_node|
        register_nodes(child_node)
      end
    end

    def find_nodes(node_classes, token: nil)
      node_classes = Array(node_classes)
      result = @nodes.select {|node| node_classes.include?(node.class)}
      token.present? ? result.select {|node| node.token_value == token} : result
    end

    def variables(token: nil)
      find_nodes(
        [
          Prism::LocalVariableWriteNode,
          Prism::LocalVariableReadNode,
          Prism::RequiredParameterNode
        ],
        token: token
      )
    end

    def strings(token: nil)
      find_nodes(Prism::StringNode, token: token)
    end

    def all_methods(token: nil)
      order_nodes(method_definitions(token: token) + method_calls(token: token))
    end

    def method_definitions(token: nil)
      find_nodes(Prism::DefNode, token: token)
    end

    def method_calls(token: nil)
      find_nodes(Prism::CallNode, token: token)
    end

    def symbols(token: nil)
      find_nodes(Prism::SymbolNode, token: token)
    end

    def symbol_literals(token: nil)
      result = find_nodes(Prism::SymbolNode, token: token)

      # TODO: Describe why closing_loc has to happen.
      result.select{|node| node.closing_loc.nil?}
    end

    def string_symbols(token: nil)
      result = find_nodes(Prism::SymbolNode, token: token)

      # TODO: Describe why closing_loc has to happen.
      result.reject{|node| node.closing_loc.nil?}
    end

    # Retrieves all parameters within pipes (i.e. - |x, y, z|).
    def block_parameters
      find_nodes(Prism::BlockParametersNode)
    end

    def parameters(token: nil)
      find_nodes(Prism::ParametersNode, token: token)
    end

    def comments(token: nil)
      @prism.comments
    end

    def replace(type:, old_token:, new_token:)
      Slasher.replace(
        type: type,
        old_token: old_token,
        new_token: new_token,
        code: @code,
        ast: self
      )
    end

    private

    # Order results according to their token location.
    def order_nodes(nodes)
      nodes.sort do |a, b|
        by_line = a.token_location.start_line <=> b.token_location.start_line
        # If we're on the same line, refer to the inner index for order.
        by_line.zero? ? a.token_location.start_column <=> b.token_location.start_column : by_line
      end
    end
  end
end
