module Masamune
  class AbstractSyntaxTree
    class SearchVisitor < Prism::Visitor
      attr_accessor :results
      attr_accessor :search_types

      def initialize
        @results = []
        @search_types = []
        super
      end

      def visit(node)
        clear_results
        @search_types = Array(@search_types)
        @search_types.each {|type| self.send("visit_#{type}", node)}
        super
      end

      %w(
        local_variable_write_node
        local_variable_read_node
        required_parameter_node
        string_node
        def_node
        call_node
        symbol_node
        block_parameters_node
        parameters_node
      ).each do |node_name|
        define_method("visit_#{node_name}") do |node|
          @results << node if @search_types.include?(symbolized_class(node)) && !results.include?(node)
          super(node)
        end
      end

      def clear_results
        @results = []
      end

      private

      def symbolized_class(node)
        node.class.name.split("::").pop.underscore.to_sym
      end
    end
  end
end
