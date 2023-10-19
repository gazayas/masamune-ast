module Prism
  class Node
    def comment? = false

    def self.node_predicate(name, body = -> { true })
      define_method(name, &body)
      Node.define_method(name) { false } unless Node.respond_to?(name, false)
    end

    def line_number
      token_location.start_line
    end

    # #location provides helpful information for the source code of a node as a whole, but in
    # Masamune we generally want the token value itself, so we primarily get the token value's location.
    def token_location
      location
    end

    # The source code of Prism nodes can be retrieved by calling #slice.
    # However, the output tends to vary from node to node, and other methods
    # like `name`, `message`, etc. are available in Prism nodes which means you
    # have to know exactly which method to call the get the results you want.
    #
    # The `token` method simplifies all of this, and just gives you the
    # variable, method name, etc. in String form by just calling `token_value`.
    def token_value
      content
    end
  end

  class DefNode
    node_predicate :method?
    node_predicate :method_definition?
    def token_location = name_loc
    def token_value = name.to_s
  end

  class CallNode
    def method? = true
    node_predicate :method_call?
    def token_location = message_loc
    def token_value = message
  end

  class LocalVariableWriteNode
    node_predicate :variable?
    def token_location = name_loc
    def token_value = name.to_s
  end

  class LocalVariableReadNode
    def variable? = true
    def token_value = name.to_s
  end

  class RequiredParameterNode
    def variable? = true
    def token_value = slice
  end

  class StringNode
    node_predicate :string?
    def token_location = content_loc
    def token_value = content
  end

  class SymbolNode
    node_predicate :symbol?
    node_predicate :symbol_literal?, -> { closing_loc.nil? }
    node_predicate :symbol_string?, -> { closing_loc.present? }

    def token_location = value_loc
    def token_value = value
  end

  class Comment
    def comment? = true
    def token_location = location
    def token_value = location.slice
    def start_line = location.start_line
    def start_column = location.start_column
    def end_line = location.end_line
    def end_column = location.end_column
    def line_number = start_line
  end
end
