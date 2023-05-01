module Masamune
  class AbstractSyntaxTree
    attr_reader :data
    attr_accessor :lex_nodes, :debug

    def initialize(code)
      @data = Ripper.sexp(code)
      raw_lex_nodes = Ripper.lex(code)
      @lex_nodes = raw_lex_nodes.map do |lex_node|
        Masamune::LexNode.new(raw_lex_nodes.index(lex_node), lex_node, self.__id__)
      end
      @debug = false
    end

    def tree_nodes
      raise "Set `debug` to `true` to display the tree nodes" unless @debug
      search # Perform search with no conditions.
    end

    def variables
      search(:variable)
    end

    def all_methods
      method_definitions + method_calls
    end

    def method_definitions
      search(:def)
    end

    def method_calls
      search(:method_call)
    end

    def strings
      search(:string)
    end

    def data_nodes
      search(:data_node)
    end

    def search(type = nil, token = nil, tree_node = self.data, result = [])
      return if !tree_node.is_a?(Array) || (tree_node.is_a?(Array) && tree_node.empty?)
      debug_output(tree_node) if @debug

      # If the first element is an array, then we're getting all arrays so we just continue the search.
      if tree_node.first.is_a?(Array)
        tree_node.each { |node| search(type, token, node, result) }
      elsif tree_node.first.is_a?(Symbol)
        if has_data_node?(tree_node)
          register_result = case type
          when :variable
            tree_node.first == :var_field || tree_node.first == :var_ref
          when :string
            tree_node.first == :string_content
          when :def
            tree_node.first == :def
          when :method_call
            tree_node.first == :vcall
          end

          if register_result
            # TODO: AbstractSyntaxTree::DataNode.new(tree_node)
            # For most tree nodes, the data_node is housed in the second element.
            position, data_node_token = data_node_parts(tree_node[1])

            # Gather all results if token isn't specified.
            result << [position, data_node_token] if token == data_node_token || token.nil?
          end

          # Continue search for all necessary elements.
          case tree_node.first
          when :def, :command
            tree_node.each { |node| search(type, token, node, result) }
          end

        # The data nodes in :call nodes are in a different place within the array, so we handle that here.
        # These :call nodes represent methods and chained methods like `[1, 2, 3].sum.times`.
        elsif (type == :method_call && tree_node.first == :call)
          # The method inside the [:call, ...] data node is the last element in the array.
          position, data_node_token = data_node_parts(tree_node.last)
          result << [position, data_node_token] if token == data_node_token || token.nil?
          # The second element is where more :call nodes are nested, so we search it.
          search(type, token, tree_node[1], result)
        else
          # Simply continue the search for all other nodes.
          tree_node.each { |node| search(type, token, node, result) }
        end
      end

      result
    end

    private

    # A data node represents an abstraction in the AST which has details about a specific command.
    # i.e. - [:@ident, "variable_name", [4, 7]]
    # These values are the `type`, `token`, and `position`, respectively.
    # It is simliar to what you see in `Ripper.lex(code)` and `Masamune::Base's @lex_nodes`.
    # Data nodes serve as a base case when recursively searching the AST.
    #
    # The parent node's first element houses the type of action being performed:
    # i.e. - [:assign, [:@ident, "variable_name", [4, 7]]]
    # `has_data_node?` is performed on a parent node.
    def has_data_node?(node)
      node[1].is_a?(Array) && node[1][1].is_a?(String)
    end

    def data_node_parts(tree_node)
      _, token, position = tree_node
      [position, token]
    end

    def is_line_position?(tree_node)
      tree_node.size == 2 && tree_node.first.is_a?(Integer) && tree_node.last.is_a?(Integer)
    end

    def debug_output(tree_node)
      puts "==================================" # TODO: Track the array depth and output the number here.
      puts "=================================="
      p tree_node
    end
  end
end
