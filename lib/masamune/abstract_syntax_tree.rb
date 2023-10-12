require_relative "abstract_syntax_tree/prism/node_extensions"

module Masamune
  class AbstractSyntaxTree
    attr_reader :code, :prism, :ripper
    attr_accessor :lex_nodes

    def initialize(code)
      @code = code
      @prism = Prism.parse(code)
      @ripper = Ripper.sexp(code)
      raw_lex_nodes = Ripper.lex(code)
      @lex_nodes = raw_lex_nodes.map do |lex_node|
        LexNode.new(raw_lex_nodes.index(lex_node), lex_node, self.__id__)
      end
    end

    def variables(token_value: nil)
      visitor = VariablesVisitor.new(token_value)
      @prism.value.accept(visitor)
      visitor.results
    end

    def strings(token_value: nil)
      visitor = StringsVisitor.new(token_value)
      @prism.value.accept(visitor)
      visitor.results
    end

    def all_methods(token_value: nil)
      order_nodes(method_definitions(token_value: token_value) + method_calls(token_value: token_value))
    end

    def method_definitions(token_value: nil)
      visitor = MethodDefinitionsVisitor.new(token_value)
      @prism.value.accept(visitor)
      visitor.results
    end

    def method_calls(token_value: nil)
      visitor = MethodCallsVisitor.new(token_value)
      @prism.value.accept(visitor)
      visitor.results
    end

    def symbols(token_value: nil)
      visitor = SymbolsVisitor.new(token_value)
      @prism.value.accept(visitor)
      visitor.results
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
      visitor = BlockParametersVisitor.new
      @prism.value.accept(visitor)
      visitor.results
    end

    def parameters(token_value: nil)
      visitor = ParametersVisitor.new(token_value)
      @prism.value.accept(visitor)
      visitor.results
    end

    # TODO: Search by token_value if necessary.
    def comments
      @prism.comments
    end

    def replace(type:, old_token_value:, new_token_value:)
      Slasher.replace(
        type: type,
        old_token_value: old_token_value,
        new_token_value: new_token_value,
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
