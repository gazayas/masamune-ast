# A data node represents an abstraction in the AST which has details about a specific type.
# i.e. - [:@ident, "variable_name", [4, 7]]
# These values are the `type`, `token`, and `position`, respectively.
# It is simliar to what you see in `Ripper.lex(code)` and `Masamune::AbstractSyntaxTree's @lex_nodes`.
# Data nodes serve as a base case when recursively searching the AST.

class Masamune::AbstractSyntaxTree::DataNode << Masamune::AbstractSyntaxTree::Node
  def initialize(contents)
    @type, @token, @line_position = contents

    # TODO
    # @corresponding_lex_node

    super
  end
end
