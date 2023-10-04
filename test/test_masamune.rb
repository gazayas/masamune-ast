# frozen_string_literal: true

require "test_helper"

class TestMasamune < Minitest::Test
  def test_find_nodes
    code = <<~CODE
      "first string"
      "second string"
      # comment
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(code)
    strings = msmn.find_nodes(Masamune::AbstractSyntaxTree::StringContent)
    comments = msmn.find_nodes(Masamune::AbstractSyntaxTree::Comment)

    assert_equal strings.size, 2
    assert_equal strings.first, {line_number: 1, index_on_line: 1, token: "first string"}
    assert_equal strings.last, {line_number: 2, index_on_line: 1, token: "second string"}
    assert_equal comments.size, 1
    assert_equal comments.first, {:line_number=>3, :index_on_line=>0, :token=>"# comment\n"}
  end

  def test_find_variable
    similar_tokens = <<~CODE
      java = "java"
      javascript = java + "script"
      p java
      # java (Doesn't pick up comments)
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(similar_tokens)
    assert msmn.variables.size == 4
    assert msmn.variables(name: "java").size == 3
    assert msmn.variables(name: "javascript").size == 1
  end

  def test_find_string
    strings = <<~CODE
      foo = "foo"
      bar = "bar"
      puts "foo bar"
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(strings)
    assert msmn.strings.size == 3
    assert msmn.strings(content: "foo").size == 1
    assert msmn.strings(content: "bar").size == 1
    assert msmn.strings(content: "foo bar").size == 1
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
    assert msmn.all_methods.size == 4
    assert msmn.method_calls.size == 3
    assert msmn.method_definitions.size == 1
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
    assert methods.size == 8

    method_names = methods.map {|m| m[:token]}
    assert method_names.include?("sum")
    assert method_names.include?("times")

    # Picks up ary, n, z, k, and v.
    assert msmn.variables.size == 9

    # Check block params and their line positions.
    assert msmn.block_params.size == 4
    assert msmn.block_params.first == {line_number: 4, index_on_line: 18, token: "n"}
    assert msmn.block_params.last == {line_number: 11, index_on_line: 23, token: "v"}
  end

  def test_find_comments
    comments = <<~CODE
      # First comment
      # Second comment
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(comments)

    # Comments don't have a data node in @tree.
    assert msmn.data_node_list.empty?
    assert msmn.comments.size == 2
    assert msmn.comments.first[:token] == "# First comment\n"
  end

  def test_find_symbols
    symbol_literals = <<~CODE
      "foo"
      :foo
      :bar
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(symbol_literals)
    assert msmn.symbols.size == 2
    assert msmn.symbols.first == {line_number: 2, index_on_line: 1, token: "foo"}
    assert msmn.symbols.last == {line_number: 3, index_on_line: 1, token: "bar"}

    x = "foo"
    y = "bar"
    string_symbols = <<~CODE
      :"#{x}_#{y}"
      :not_a_string_symbol
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(string_symbols)
    assert msmn.symbols.size == 2
    assert msmn.string_symbols.size == 1
    assert msmn.string_symbols.first[:line_number] == 1
    assert msmn.string_symbols.first[:index_on_line] == 2
    assert msmn.string_symbols.first[:token] == "foo_bar"
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

  def test_return_data_nodes
    vars = <<~CODE
      "foo"
      "bar"
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(vars)
    nodes = msmn.strings(result_type: :nodes)
    assert nodes.size == 2
    assert nodes.first.data_nodes.first.line_data_and_token[:line_number] == 1
    assert nodes.first.data_nodes.first.line_data_and_token[:index_on_line] == 1
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

    # Since `all_methods` combines two searches
    # (`method_definitions` and `method_calls`),
    # we ensure these results are ordered with
    # order_results(results).
    results = msmn.all_methods
    expected_results = [
      {:line_number=>2, :index_on_line=>4, :token=>"sum"},
      {:line_number=>2, :index_on_line=>8, :token=>"times"},
      {:line_number=>3, :index_on_line=>2, :token=>"puts"},
      {:line_number=>6, :index_on_line=>4, :token=>"foo"},
      {:line_number=>8, :index_on_line=>0, :token=>"foo"},
      {:line_number=>9, :index_on_line=>0, :token=>"foo"}
    ]

    assert_equal expected_results, results
  end
end
