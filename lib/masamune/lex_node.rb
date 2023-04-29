module Masamune
  # https://docs.ruby-lang.org/en/3.0/Ripper.html#method-c-lex
  #
  # @position: Line number and starting point on the line. i.e. - [4, 7].
  # @type: The type of token. i.e. - :kw (is a keyword).
  # @token: The raw string which represents the actual ruby code. i.e. - "do".
  # @state: Ripper::Lexer::State. i.e. - CMDARG.
  class LexNode
    attr_accessor :position, :type, :token, :state, :ast_id
    attr_reader :index

    def initialize(index, raw_lex_node, ast_id)
      @index = index
      @position, @type, @token, @state = raw_lex_node
      @type = @type.to_s.gsub(/^[a-z]*_/, "").to_sym

      # Since the Abstract Syntax Tree can get very large,
      # We just save the id and reference it with `ast` below.
      @ast_id = ast_id
    end

    def ast
      ObjectSpace._id2ref(@ast_id)
    end

    def is_variable?
      return false unless is_identifier?
      ast.search(:variable, @token).any?
    end

    def is_method?
      return false unless is_identifier?
      is_method_definition? || is_method_call?
    end

    def is_method_definition?
      ast.search(:def, @token).any?
    end

    def is_method_call?
      ast.search(:method_call, @token).any?
    end

    def is_identifier?
      type == :ident
    end

    def is_string?
      type == :tstring_content
    end
  end
end
