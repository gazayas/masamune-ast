module Masamune
  class AbstractSyntaxTree
    attr_reader :data
    attr_accessor :node_list, :data_node_list, :lex_nodes

    def initialize(code)
      @data = Ripper.sexp(code)
      raw_lex_nodes = Ripper.lex(code)
      @lex_nodes = raw_lex_nodes.map do |lex_node|
        Masamune::LexNode.new(raw_lex_nodes.index(lex_node), lex_node, self.__id__)
      end

      @node_list = []
      @data_node_list = []
      register_nodes(@data) # Nodes are registered here to @node_list and @data_node_list.
    end

    def register_nodes(tree_node = self.data)
      begin
        if tree_node.is_a?(Array)
          class_name = "Masamune::AbstractSyntaxTree::#{tree_node.first.to_s.camelize}"
          klass = class_name.constantize
          msmn_node = klass.new(tree_node, self.__id__)
        else
          msmn_node = Masamune::AbstractSyntaxTree::Node.new(tree_node, self.__id__)
        end

      # For all other nodes that we haven't covered yet, we just make a general class.
      # We can worry about adding the classes for other nodes as we go.
      rescue NameError
        msmn_node = Masamune::AbstractSyntaxTree::Node.new(tree_node, self.__id__)
      end

      # Register nodes
      @node_list << msmn_node
      msmn_node.data_nodes.each { |dn| @data_node_list << dn } if msmn_node.data_nodes

      # Continue down the tree until base case is reached.
      if !msmn_node.nil? && msmn_node.contents.is_a?(Array)
        msmn_node.contents.each { |node| register_nodes(node) }
      end
    end

    def variables(name: nil)
      var_nodes = @node_list.select do |node|
        node.class == Masamune::AbstractSyntaxTree::VarField ||
        node.class == Masamune::AbstractSyntaxTree::VarRef
      end

      if name
        var_nodes = var_nodes.select do |node|
          node.data_nodes.first.token == name
        end
      end

      # Return the token along with its line position.
      var_nodes.map do |node|
        node.data_nodes.map {|dn| dn.position_and_token}.flatten
      end
    end

    def all_methods
      method_definitions + method_calls
    end

    def method_definitions
      # TODO: Grab from @node_list
      # :def
    end

    def method_calls
      # TODO: Grab from @node_list
      # :method_call
    end

    # TODO: Potentially split this into do_block_params and brace_block_params.
    def block_params
      # TODO: Grab from @node_list
      # :block_param
    end

    def strings
      # TODO: Make a class for :string_content
      # @node_list.select {|node| node.type == :string_content}
    end
  end
end
