module Masamune
  class AbstractSyntaxTree
    attr_reader :code, :tree, :comment_list
    attr_accessor :node_list, :data_node_list, :lex_nodes

    def initialize(code)
      @code = code
      @tree = Ripper.sexp(code)
      raw_lex_nodes = Ripper.lex(code)
      @lex_nodes = raw_lex_nodes.map do |lex_node|
        LexNode.new(raw_lex_nodes.index(lex_node), lex_node, self.__id__)
      end

      @node_list = []
      @data_node_list = []
      @comment_list = []
      register_nodes(@tree)

      # Refer to Masamune::AbstractSyntaxTree::Comment
      # to see why we register these separately.
      register_comments
    end

    def register_nodes(tree_node = self.tree)
      if tree_node.is_a?(Array)
        klass = get_node_class(tree_node.first)
        msmn_node = klass.new(tree_node, self.__id__)
      else
        # Create a general node if the node is a single value.
        msmn_node = Node.new(tree_node, self.__id__)
      end

      # Register nodes and any data nodes housed within it.
      # See Masamune::AbstractSyntaxTree::DataNode for more details on what a data node is.
      @node_list << msmn_node
      msmn_node.data_nodes.each { |dn| @data_node_list << dn } if msmn_node.data_nodes

      # Continue down the tree until base case is reached.
      if !msmn_node.nil? && msmn_node.contents.is_a?(Array)
        msmn_node.contents.each { |node| register_nodes(node) }
      end
    end

    def register_comments
      comment_lex_nodes = @lex_nodes.select {|node| node.type == :comment}.flatten
      @comment_list << comment_lex_nodes.map {|node| Comment.new(node, self.__id__)}
      @comment_list.flatten!
    end

    # TODO: Add block_params: true to the arguments.
    def variables(name: nil, data_nodes: false)
      var_classes = [
        :var_field,
        :var_ref,
        :params
      ].map {|type| get_node_class(type)}
      find_nodes(var_classes, token: name, data_nodes: data_nodes)
    end

    def strings(content: nil, data_nodes: false)
      find_nodes(get_node_class(:string_content), token: content, data_nodes: data_nodes)
    end

    def method_definitions(name: nil, data_nodes: false)
      find_nodes(get_node_class(:def), token: name, data_nodes: data_nodes)
    end

    def method_calls(name: nil, data_nodes: false)
      method_classes = [
        :vcall,
        :call
      ].map {|type| get_node_class(type)}
      find_nodes(method_classes, token: name, data_nodes: data_nodes)
    end

    # TODO
    def do_block_params
    end

    # TODO
    def brace_block_params
    end

    def symbols(content: nil, data_nodes: false)
      symbol_literals(content: content, data_nodes: data_nodes) + string_symbols(content: content, data_nodes: data_nodes)
    end

    def symbol_literals(content: nil, data_nodes: false)
      find_nodes(get_node_class(:symbol_literal), token: content, data_nodes: data_nodes)
    end

    def string_symbols(content: nil, data_nodes: false)
      find_nodes(get_node_class(:dyna_symbol), token: content, data_nodes: data_nodes)
    end

    def comments(content: nil, data_nodes: false)
      find_nodes(get_node_class(:comment), token: content, data_nodes: false)
    end

    def all_methods(name: nil, data_nodes: false)
      method_definitions(name: name, data_nodes: data_nodes) + method_calls(name: name, data_nodes: data_nodes)
    end

    def block_params(content: nil, data_nodes: false)
      # TODO: do_block_params + brace_block_params
      find_nodes(get_node_class(:params), token: content, data_nodes: data_nodes)
    end

    def find_nodes(token_classes, token: nil, data_nodes: false)
      # Ensure the classes are in an array
      token_classes = [token_classes].flatten

      nodes = []
      token_classes.each do |klass|
        if klass == Masamune::AbstractSyntaxTree::Comment
          nodes = @comment_list.dup
        else
          nodes << @node_list.select {|node| node.class == klass}
        end
      end

      # Searching for multiple classes will yield multi-dimensional arrays,
      # so we ensure everything is flattened out before moving forward.
      nodes.flatten!

      if token
        # TODO: This most likely shouldn't be `node.data_nodes.first`.
        # There are probably more data_nodes we need to check depending on the node class.
        nodes = nodes.select {|node| node.data_nodes.first.token == token}.flatten
      end

      final_result = []
      nodes.each do |node|
        # Data for symbols are housed within a nested node, so we handle those differently here.
        # Read the comments for `get_symbol_data` in the symbol node classes for details.
        if node.class == Masamune::AbstractSyntaxTree::SymbolLiteral || node.class == Masamune::AbstractSyntaxTree::DynaSymbol
          final_result << (data_nodes ? node : node.get_symbol_data.position_and_token)
        else
          node.data_nodes.each {|dn| final_result << (data_nodes ? dn : dn.position_and_token)} if node.data_nodes
        end
      end

      # Only order the information if we're returning hashes.
      # TODO: We might want to change the placement of order_results_by_position
      # if the operation is being done against hashes and not data nodes.
      data_nodes ? final_result : DataNode.order_results_by_position(final_result)
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

    def get_node_class(type)
      begin
        "Masamune::AbstractSyntaxTree::#{type.to_s.camelize}".constantize
      rescue NameError
        # For all other nodes that we haven't covered yet, we just make a general class.
        # We can worry about adding the classes for other nodes as we go.
        Node
      end
    end
  end
end
