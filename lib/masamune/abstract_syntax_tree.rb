require_relative "abstract_syntax_tree/prism/node_extensions"
require_relative "abstract_syntax_tree/visitors/search_visitor"

module Masamune
  class AbstractSyntaxTree
    attr_reader :code, :tree, :prism
    attr_accessor :lex_nodes, :visitor

    def initialize(code)
      @code = code
      @tree = Ripper.sexp(code)
      raw_lex_nodes = Ripper.lex(code)
      @lex_nodes = raw_lex_nodes.map do |lex_node|
        LexNode.new(raw_lex_nodes.index(lex_node), lex_node, self.__id__)
      end

      @prism = Prism.parse(code)
      @visitor = SearchVisitor.new
    end

    def variables(token_value: nil)
      @visitor.search_types = [
        :local_variable_write_node,
        :local_variable_read_node,
        :required_parameter_node
      ]
      perform_search(token_value: token_value)
    end

    def strings(token_value: nil)
      @visitor.search_types = :string_node
      perform_search(token_value: token_value)
    end

    def all_methods(token_value: nil)
      order_nodes(method_definitions(token_value: token_value) + method_calls(token_value: token_value))
    end

    def method_definitions(token_value: nil)
      @visitor.search_types = :def_node
      perform_search(token_value: token_value)
    end

    def method_calls(token_value: nil)
      @visitor.search_types = :call_node
      perform_search(token_value: token_value)
    end

    def symbols(token_value: nil)
      @visitor.search_types = :symbol_node
      perform_search(token_value: token_value)
    end

    def symbol_literals(token_value: nil)
      result = symbols(token_value: token_value)

      # TODO: Describe why closing_loc has to happen.
      result.select{|node| node.closing_loc.nil?}
    end

    def string_symbols(token_value: nil)
      result = symbols(token_value: token_value)

      # TODO: Describe why closing_loc has to happen.
      result.reject{|node| node.closing_loc.nil?}
    end

    # Retrieves all parameters within pipes (i.e. - |x, y, z|).
    def block_parameters
      @visitor.search_types = :block_parameters_node
      perform_search
    end

    def parameters(token_value: nil)
      @visitor.search_types = :parameters_node
      perform_search(token_value: token_value)
    end

    def comments(token: nil)
      @prism.comments
    end

    def perform_search(token_value: nil)
      @visitor.visit(@prism.value)
      @visitor.results = order_nodes(@visitor.results)
      token_value.present? ? @visitor.results.select{|res| res.token_value == token_value} : @visitor.results
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
