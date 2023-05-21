module Masamune
  class AbstractSyntaxTree
    attr_reader :data
    attr_accessor :node_list, :lex_nodes

    def initialize(code)
      @data = Ripper.sexp(code)
      @node_list = []
      @data_nodes = []

      raw_lex_nodes = Ripper.lex(code)
      @lex_nodes = raw_lex_nodes.map do |lex_node|
        Masamune::LexNode.new(raw_lex_nodes.index(lex_node), lex_node, self.__id__)
      end
    end

    # TODO: Change to register_tree_nodes, add to initializer.
    def parse(tree_node = self.data)
      begin
        # Here we create general nodes in the `else` statement if the node is a single value.
        if tree_node.is_a?(Array)
          class_name = "Masamune::AbstractSyntaxTree::#{tree_node.first.to_s.camelize}"
          klass = class_name.constantize
          msmn_node = klass.new(tree_node, self.__id__)
        else
          msmn_node = Masamune::AbstractSyntaxTree::Node.new(tree_node, self.__id__)
        end

      # For all other nodes that we haven't covered yet, we just make a general class.
      # We can worry about adding the classes for other nodes later.
      rescue NameError
        msmn_node = Masamune::AbstractSyntaxTree::Node.new(tree_node, self.__id__)
      end

      # Register nodes.
      @node_list << msmn_node
      # TODO: Create the class inside msmn_node, then push the data nodes from there to the list.
      # msmn_node.data_nodes.each { |dn| @data_nodes << dn } if msmn_node.data_nodes

      # Continue parsing until base case is reached.
      if !msmn_node.nil? && msmn_node.contents.is_a?(Array)
        msmn_node.contents.each { |node| parse(node) }
      end
    end

    def variables(var_name:)
      var_nodes = @node_list.select do |node|
        node.class == Masamune::AbstractSyntaxTree::VarField ||
        node.class == Masamune::AbstractSyntaxTree::VarRef
      end
      get_data_nodes_from(var_nodes)
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

    # TODO: Potentially split this into do_block_params and brace_block_params.
    def block_params
      search(:block_param)
    end

    def strings
      @node_list.select {|node| node.type == :string_content}
    end

    def data_nodes
      @node_list.select {|node| node.is_a?(Masamune::AbstractSyntaxTree::DataNode)}
    end

    # Extract all data nodes from parsed msmn nodes, not Ripper.sexp's raw output.
    def get_data_nodes_from(msmn_nodes)
      msmn_nodes.map do |node|
        node.data_nodes.map do |dn|
          dn = Masamune::AbstractSyntaxTree::DataNode.new(dn, self.__id__)
          [dn.line_position, dn.token]
        end.flatten # TODO: I don't really like having `flatten` here.
      end
    end
  end
end
