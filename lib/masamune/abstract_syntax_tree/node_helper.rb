module Masamune::AbstractSyntaxTree::NodeHelper
  # The source code of Prism nodes can be retrieved by calling #slice.
  # However, the output tends to vary from node to node, and other methods
  # like `name`, `message`, etc. are available in Prism nodes which means you
  # have to know exactly which method to call the get the results you want.
  #
  # The `token` method simplifies all of this, and just gives you the
  # variable, method name, etc. in String form by just calling `token`.
  def token
    if variable?
      if self.class == Prism::RequiredParameterNode
        slice
      else
        name.to_s
      end
    elsif string?
      content
    elsif method_definiton?
      name.to_s
    elsif method_call?
      message
    elsif symbol?
      value
    end
  end

  # #location provides helpful information for the source code of a node as a whole,
  # but in Masamune we generally want the token itself, so we primarily get the token's location.
  def token_location
    if variable?
      if self.class == Prism::LocalVariableWriteNode
        name_loc
      else
        location
      end
    elsif symbol?
      value_loc
    elsif method_definiton?
      name_loc
    elsif method_call?
      message_loc
    else
      location
    end
  end

  def line_number
    token_location.start_line
  end

  def variable?
    [
      Prism::LocalVariableWriteNode,
      Prism::LocalVariableReadNode,
      Prism::RequiredParameterNode
    ].include?(self.class)
  end

  def string?
    is_a?(Prism::StringNode)
  end

  def method?
    method_definiton? || method_call?
  end

  def method_definiton?
    is_a?(Prism::DefNode)
  end

  def method_call?
    is_a?(Prism::CallNode)
  end

  def symbol?
    symbol_literal? || symbol_string?
  end

  def symbol_literal?
    is_a?(Prism::SymbolNode) && closing_loc.nil?
  end

  def symbol_string?
    is_a?(Prism::SymbolNode) && closing_loc.present?
  end

  def comment?
    is_a?(Masamune::AbstractSyntaxTree::Comment)
  end
end
