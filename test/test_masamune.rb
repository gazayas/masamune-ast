# frozen_string_literal: true

require "test_helper"

class TestMasamune < Minitest::Test
  def test_find_variable
    similar_tokens = <<~CODE
      java = "java"
      javascript = java + "script"
      p java
      # java (Doesn't pick up comments)
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(similar_tokens)
    assert_equal 4, msmn.variables.size
    assert_equal 3, msmn.variables(token_value: "java").size
    assert_equal 1, msmn.variables(token_value: "javascript").size
  end

  def test_find_string
    strings = <<~CODE
      foo = "foo"
      bar = "bar"
      puts "foo bar"
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(strings)
    assert_equal 3, msmn.strings.size
    assert_equal 1, msmn.strings(token_value: "foo").size
    assert_equal 1, msmn.strings(token_value: "bar").size
    assert_equal 1, msmn.strings(token_value: "foo bar").size
  end

  def test_find_method_and_string
    methods = <<~CODE
      def foo
        puts "foo"
      end
      foo
      foo # Call foo again.
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(methods)
    assert_equal 4, msmn.all_methods.size
    assert_equal 3, msmn.method_calls.size
    assert_equal 1, msmn.method_definitions.size
  end

  def test_chained_method_calls
    blocks = <<~CODE
      ary = [1, 2, 3]

      # Picks up :do_block params.
      ary.sum.times do |n|
        puts n
      end

      # Picks up :brace_block params.
      ary.sum.times {|z| puts z}

      {foo: "bar"}.each {|k, v| puts "Picks up multiple params"}
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(blocks)
    methods = msmn.all_methods
    assert_equal 8, methods.size

    method_names = methods.map(&:token_value)
    assert_includes method_names, "sum"
    assert_includes method_names, "times"

    # Picks up ary, n, z, k, and v.
    assert_equal 9, msmn.variables.size
  end

  def test_find_comments
    comments = <<~CODE
      # First comment
      # Second comment
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(comments)

    assert_equal 2, msmn.comments.size
    assert_equal "# First comment", msmn.comments.first.token_value

    # Test location
    assert_equal 1, msmn.comments.first.line_number
    assert_equal 2, msmn.comments.last.line_number
  end

  def test_find_symbols
    symbol_literals = <<~CODE
      "foo"
      :foo
      :bar
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(symbol_literals)
    assert_equal 2, msmn.symbols.size
    assert_equal "foo", msmn.symbols.first.token_value
    assert_equal "bar", msmn.symbols.last.token_value

    x = "foo"
    y = "bar"
    string_symbols = <<~CODE
      :"#{x}_#{y}"
      :not_a_string_symbol
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(string_symbols)
    assert_equal 2, msmn.symbols.size
    assert_equal 1, msmn.string_symbols.size
    assert_equal 1, msmn.string_symbols.first.line_number
    assert_equal 2, msmn.string_symbols.first.token_location.start_column
    assert_equal "foo_bar", msmn.string_symbols.first.token_value
  end

  def test_lex_nodes_return_proper_type
    similar_tokens = <<~CODE
      java = "java"
      javascript = java + "script"
      p java
      # java (Doesn't pick up comments)
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(similar_tokens)
    assert msmn.lex_nodes.first.variable?
    refute msmn.lex_nodes.first.method?
    refute msmn.lex_nodes.first.string?
  end

  def test_order_results
    code = <<~CODE
      ary = [1, 2, 3]
      ary.sum.times do |n|
        puts n
      end

      def foo
      end
      foo
      foo # Call again
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(code)

    # Since `all_methods` combines two searches (`method_definitions` and `method_calls`),
    # we ensure these results are ordered with order_nodes(nodes).
    method_nodes = msmn.all_methods
    ordered_locations = method_nodes.map {|node| [node.token_location.start_line, node.token_location.start_column]}
    expected_results = [
      [2, 4],
      [2, 8],
      [3, 2],
      [6, 4],
      [8, 0],
      [9, 0]
    ]

    assert_equal expected_results, ordered_locations
  end
end
