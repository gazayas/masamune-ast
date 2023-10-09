# frozen_string_literal: true

require "test_helper"

class TestMasamune < Minitest::Test
  def test_find_nodes
    code = <<~CODE
      "first string"
      "second string"
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(code)
    strings = msmn.find_nodes(Prism::StringNode)

    assert_equal strings.size, 2
    assert_equal strings.first.token, "first string"
    assert_equal strings.first.line_number, 1
    assert_equal strings.last.token, "second string"
    assert_equal strings.last.line_number, 2
  end

  def test_find_variable
    similar_tokens = <<~CODE
      java = "java"
      javascript = java + "script"
      p java
      # java (Doesn't pick up comments)
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(similar_tokens)
    assert_equal msmn.variables.size, 4
    assert_equal msmn.variables(token: "java").size, 3
    assert_equal msmn.variables(token: "javascript").size, 1
  end

  def test_find_string
    strings = <<~CODE
      foo = "foo"
      bar = "bar"
      puts "foo bar"
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(strings)
    assert_equal msmn.strings.size, 3
    assert_equal msmn.strings(token: "foo").size, 1
    assert_equal msmn.strings(token: "bar").size, 1
    assert_equal msmn.strings(token: "foo bar").size, 1
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
    assert_equal msmn.all_methods.size, 4
    assert_equal msmn.method_calls.size, 3
    assert_equal msmn.method_definitions.size, 1
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
    assert_equal methods.size, 8

    method_names = methods.map {|m| m.token}
    assert method_names.include?("sum")
    assert method_names.include?("times")

    # Picks up ary, n, z, k, and v.
    assert_equal msmn.variables.size, 9
  end

  def test_find_comments
    comments = <<~CODE
      # First comment
      # Second comment
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(comments)

    # Comments don't have a data node in @tree.
    assert_equal msmn.comments.size, 2
    assert_equal msmn.comments.first.token, "# First comment\n"
  end

  def test_find_symbols
    symbol_literals = <<~CODE
      "foo"
      :foo
      :bar
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(symbol_literals)
    assert_equal msmn.symbols.size, 2
    assert_equal msmn.symbols.first.token, "foo"
    assert_equal msmn.symbols.last.token, "bar"

    x = "foo"
    y = "bar"
    string_symbols = <<~CODE
      :"#{x}_#{y}"
      :not_a_string_symbol
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(string_symbols)
    assert_equal msmn.symbols.size, 2
    assert_equal msmn.string_symbols.size, 1
    assert_equal msmn.string_symbols.first.line_number, 1
    assert_equal msmn.string_symbols.first.token_location.start_column, 2
    assert_equal msmn.string_symbols.first.token, "foo_bar"
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
