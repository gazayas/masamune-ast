module Masamune
  # https://docs.ruby-lang.org/en/3.0/Ripper.html#method-c-lex
  #
  # @location: Line number and starting point on the line. i.e. - [4, 7].
  # @type: The type of token. i.e. - :kw (is a keyword).
  # @token: The raw string which represents the actual ruby code. i.e. - "do".
  # @state: Ripper::Lexer::State. i.e. - CMDARG.
  class LexNode
    attr_accessor :location, :type, :token, :state, :ast_id
    attr_reader :index

    def initialize(index, raw_lex_node, ast_id)
      @index = index
      @location, @type, @token, @state = raw_lex_node
      @type = @type.to_s.gsub(/^[a-z]*_/, "").to_sym

      # Since the Abstract Syntax Tree can get very large,
      # We just save the id and reference it with `ast` below.
      @ast_id = ast_id
    end

    def ast
      ObjectSpace._id2ref(@ast_id)
    end

    def variable?
      return false unless identifier?
      ast.variables(token_value: @token).any?
    end

    def method_definition?
      ast.method_definitions(token_value: @token).any?
    end

    def method_call?
      ast.method_calls(token_value: @token).any?
    end

    def method?
      return false unless identifier?
      method_definition? || method_call?
    end

    # TODO: I'm not sure how I feel about checking @type against the symbol directly.
    def identifier?
      @type == :ident
    end

    def string?
      @type == :tstring_content
    end
  end
end
