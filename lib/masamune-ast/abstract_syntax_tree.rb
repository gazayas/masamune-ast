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
      register_nodes(@data)
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

    # TODO: Consider adding block_params, maybe block_params: true, etc.
    def variables(name: nil)
      var_classes = [
        Masamune::AbstractSyntaxTree::VarField,
        Masamune::AbstractSyntaxTree::VarRef,
        Masamune::AbstractSyntaxTree::Params
      ]
      find_nodes(var_classes, identifier: name)
    end

    def strings(content: nil)
      find_nodes(Masamune::AbstractSyntaxTree::StringContent, identifier: content)
    end

    def method_definitions(name: nil)
      find_nodes(Masamune::AbstractSyntaxTree::Def, identifier: name)
    end

    def method_calls(name: nil)
      method_classes = [
        Masamune::AbstractSyntaxTree::Vcall,
        Masamune::AbstractSyntaxTree::Call
      ]
      find_nodes(method_classes, identifier: name)
    end

    # TODO
    def do_block_params
    end

    # TODO
    def brace_block_params
    end

    def all_methods
      method_definitions + method_calls
    end

    def block_params
      # TODO: do_block_params + brace_block_params
      find_nodes(Masamune::AbstractSyntaxTree::Params)
    end

    # TODO: Change `identifier` to `token`.
    def find_nodes(identifier_classes, identifier: nil)
      # Ensure the classes are in an array
      identifier_classes = [identifier_classes].flatten

      var_nodes = []
      identifier_classes.each do |klass|
        var_nodes << @node_list.select {|node| node.class == klass}
      end

      # Searching for multiple classes will yield multi-dimensional arrays,
      # so we ensure everything is flattened out before moving forward.
      var_nodes.flatten!

      if identifier
        var_nodes = var_nodes.select {|node| node.data_nodes.first.token == identifier}.flatten
      end

      final_result = []
      var_nodes.each do |node|
        node.data_nodes.each {|dn| final_result << dn.position_and_token}
      end

      Masamune::AbstractSyntaxTree::DataNode.order_results_by_position(final_result)
    end
  end
end
